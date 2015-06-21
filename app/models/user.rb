# User class from devise
class User < ActiveRecord::Base

  ##############################################################################
  # INCLUDES
  ##############################################################################

  include Concerns::ActiveRecordExtensions

  ##############################################################################
  # CONSTANTS
  ##############################################################################

  DEFAULT_TIMEZONE = "Pacific Time (US & Canada)"

  ##############################################################################
  # MACROS
  ##############################################################################

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  devise authentication_keys: [:login]

  ##############################################################################
  # ATTRIBUTES
  ##############################################################################

  attr_accessor :login

  ##############################################################################
  # RELATIONSHIPS
  ##############################################################################

  has_many :groups, foreign_key: :owner_id, dependent: :destroy

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  validates :email, presence: true
  validates :password, presence: true

  ##############################################################################
  # CALLBACKS
  ##############################################################################

  before_create :set_defaults

  ##############################################################################
  # SCOPES
  ##############################################################################

  ##############################################################################
  # CLASS METHODS
  ##############################################################################

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    return where(conditions).first unless login
    where(conditions).where([
      "lower(username) = :value OR
       lower(email) = :value", { value: login.downcase }]).first
  end

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  def groups?
    groups.count > 0
  end


  # TODO: unit tests
  # used for sending "system" sms's (from reminders, nudges, etc)
  def can_message? o
    return true
    # return true if admin?
    # false
  end

  # TODO: unit tests
  def pairs
    Pair.owned_by(id)
  end

  def members
    Member.owned_by(id)
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  def set_defaults
    self.time_zone ||= DEFAULT_TIMEZONE
  end

end
