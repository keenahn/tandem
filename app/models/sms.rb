# A class representing an SMS message
class Sms < ActiveRecord::Base
  include ActiveSupport::Configurable

  MAX_LENGTH = 160
  DELAY_SECONDS = 2 # between multiple messages

  validates :to_id,   presence: true
  validates :from_id, presence: true
  validates :message, presence: true
  validate :can_send?

  # attr_protected :from_number, :to_number

  belongs_to :to, polymorphic: true
  belongs_to :from, polymorphic: true

  after_validation :clean_params
  # after_create :delay_send_sms


  def dry_run?
    Sms.config.dry_run
  end

  def self.create_and_send p
    messages = Array(p.delete(:message)) # will Array'ize single elements
    # p[:message] = messages.join("\n\n")
    # s = create(p)
    # s.delay_send_sms
    messages = Array(p.delete(:message)) # will Array'ize single elements
    wait = 0
    messages.each{|m|
      s = create p.merge({message: m})
      s.delay_send_sms(wait)
      wait += DELAY_SECONDS
    }

  end

  def send_sms
    return puts(inspect) if dry_run?
    TwilioClient.sms to_number, message
  end

  def delay_send_sms wait = 0
    return puts(self) && Rails.logger.info(self) if dry_run?
    SendSmsJob.set(wait: wait.second).perform_later(self)
  end

  def to_s
    "from: #{from_number} to: #{to_number} msg: #{message}"
  end

  private

  def can_send?
    from.can_message? to
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
