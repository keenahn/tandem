class Sms < ActiveRecord::Base
  validate :present_owner
  validates :to_id,   presence: true
  validates :from_id, presence: true
  validates :message, presence: true

  validate :can_send?

  attr_protected :from_number, :to_number

  belongs_to :team_fundraiser, class_name: "Fundraiser", foreign_key: :team_fundraiser_id
  belongs_to :organization
  belongs_to :to, class_name: "User"
  belongs_to :from, class_name: "User"

  after_validation :clean_params
  after_create :send_sms

  UNSUBSCRIBE          = 1
  WELCOME              = 2
  POKE                 = 3
  FIRST_DONATION       = 4
  ALREADY_UNSUBSCRIBED = 5
  UNKNOWN_COMMAND      = 6
  INCOMING             = 7
  TWO_DAYS_LEFT        = 8
  USER_ADMIN_APPROVAL_CONFIRMED = 9

  MAX_LENGTH = 160

  def present_owner
    team_fundraiser_id.present? || organization_id.present?
  end

  # TODO: unit tests for all this shiz
  def can_send?
    if self.category == ALREADY_UNSUBSCRIBED
      errors[:base] << "The sender has disabled SMS"
      return false
    end
    return true if category == INCOMING
    return true if from_id == User::PIGGYBACKR_ADMIN_ID

    #validate the fundraiser / organization
    #and membership of to
    to_u = User.find_by_id to_id

    from_owner = nil
    if team_fundraiser_id.present?
      f = Fundraiser.find_by_id team_fundraiser_id
      unless f && f.team?
        errors[:base] << "Fundraiser does not exist or is not a team fundraiser"
        return false
      end

      from_owner = f.owner

      unless f.enable_sms
        errors[:base] << "The sender has disabled SMS"
        return false
      end

      team_member_fundraiser = f.children.not_disabled.where(owner_id: to_id, enable_sms: true).first

      unless team_member_fundraiser
        errors[:base] << "The recipient is not a team member"
        return false
      end

      # unless to_u.roles.by_fundraiser(f)
      #   errors[:base] << "The recipient is not a team member"
      #   return false
      # end
    else
      o = Organization.find_by_id organization_id
      unless o
        errors[:base] << "Invalid organization"
        return false
      end
      from_owner = o.owner
      #TODO: orgs always have SMS enabled
      #check owners of all fundraisers...
      #urgh
      if o.fundraisers.where(owner_id: to_u.id).empty?
        errors[:base] << "The recipient is not a organization member"
        return false
      end
    end

    from_u = User.find_by_id from_id
    unless from_id == User::PIGGYBACKR_ADMIN_ID
      unless from_owner == from_u
        errors[:base] << "Only the team leader can send text messages"
        return false
      end
    end

    return true
  end

  private

  def send_sms
    # TODO: move this elsewhere?
    return Rails.logger.info self.inspect if Rails.env.development?
    TwilioClient::sms to_number, message
  end

  def clean_params
    if !from_number
      a = User.find_by_id from_id
      return false unless a
      # return false unless a && a.phone_number.present?
      # TODO add this requirement back in later but we don't currently use the return number for anything.
      # Eventually we want to be able to relay messages back to the team leader or org leader
      self.from_number = a.phone_number
    end

    if !to_number
      a = User.find_by_id to_id
      return false unless a && a.phone_number.present?
      self.to_number = a.phone_number
    end

    self.message = message.squish

    unless self.from_number && self.to_number
      errors[:base] << "From number or to number is missing"
      return false
    end
    return true
  end

end
