# A class representing an SMS message
class Sms < ActiveRecord::Base

  validate :present_owner
  validates :to_id,   presence: true
  validates :from_id, presence: true
  validates :message, presence: true
  validate :can_send?

  attr_protected :from_number, :to_number

  belongs_to :to, class_name: "Member"
  belongs_to :from, class_name: "Member"

  after_validation :clean_params
  after_create :send_sms

  MAX_LENGTH = 160

  def present_owner
    # TODO
  end

  # TODO: unit tests for all this shiz
  def can_send?
    # TODO
    # unless from_id == User::PIGGYBACKR_ADMIN_ID
    #   unless from_owner == from_u
    #     errors[:base] << "Only the team leader can send text messages"
    #     return false
    #   end
    # end

    true
  end

  private

  def send_sms
    # TODO: move this elsewhere?
    return Rails.logger.info(inspect) if Rails.env.development?
    TwilioClient.sms to_number, message
  end

  def clean_params
    # TODO
    # if !from_number
    #   a = User.find_by_id from_id
    #   return false unless a
    #   # return false unless a && a.phone_number.present?
    #   # TODO: add this requirement back in later but we don't currently use the return number for anything.
    #   # Eventually we want to be able to relay messages back to the team leader or org leader
    #   self.from_number = a.phone_number
    # end

    # if !to_number
    #   a = User.find_by_id to_id
    #   return false unless a && a.phone_number.present?
    #   self.to_number = a.phone_number
    # end

    # self.message = message.squish

    # unless from_number && to_number
    #   errors[:base] << "From number or to number is missing"
    #   return false
    # end
    # return true
  end

end
