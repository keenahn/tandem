# A class representing an SMS message
class Sms < ActiveRecord::Base

  include ActiveSupport::Configurable

  validates :to_id,   presence: true
  validates :from_id, presence: true
  validates :message, presence: true
  validate :can_send?

  # attr_protected :from_number, :to_number

  belongs_to :to, polymorphic: true
  belongs_to :from, polymorphic: true

  after_validation :clean_params
  after_create :delay_send_sms

  MAX_LENGTH = 160

  def dry_run?
    Sms.config.dry_run
  end

  def send_sms
    return Rails.logger.info(inspect) if dry_run?
    TwilioClient.sms to_number, message
  end

  private

  def can_send?
    from.can_message? to
  end

  def delay_send_sms
    return Rails.logger.info(inspect) if dry_run?
    SendSmsJob.perform_later self
  end


  # TODO: internationalize
  def clean_params
    self.from_number = from.try(:phone_number) unless from_number
    self.to_number   = to.try(:phone_number) unless to_number
    self.message     = message.squish

    unless from_number && to_number
      errors[:base] << "From number or to number is missing"
      return false
    end
    true
  end

end
