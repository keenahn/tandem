# User class from devise
class User < ActiveRecord::Base

  DEFAULT_TIMEZONE = "Pacific Time (US & Canada)"

  attr_accessor :login

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  devise authentication_keys: [:login]

  has_many :groups, foreign_key: :owner_id, dependent: :destroy

  validates :email, presence: true
  validates :password, presence: true

  before_create :set_defaults

  #->Prelang (user_login:devise/username_login_support)
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def groups?
    groups.count > 0
  end

  private

  def set_defaults
    self.time_zone ||= DEFAULT_TIMEZONE
  end

end
