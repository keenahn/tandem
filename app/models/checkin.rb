class Checkin < ActiveRecord::Base


  ##############################################################################
  # INCLUDES
  ##############################################################################

  ##############################################################################
  # CONSTANTS
  ##############################################################################

  ##############################################################################
  # MACROS
  ##############################################################################

  ##############################################################################
  # ATTRIBUTES
  ##############################################################################

  ##############################################################################
  # RELATIONSHIPS
  ##############################################################################

  belongs_to :member
  belongs_to :pair


  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  validates :member,     presence: true
  validates :pair,       presence: true
  validates :local_date, presence: true

  validates :local_date, uniqueness: {scope: [:member_id, :pair_id]}

  ##############################################################################
  # CALLBACKS
  ##############################################################################

  before_validation(on: :create){ set_defaults }

  ##############################################################################
  # SCOPES
  ##############################################################################

  ##############################################################################
  # CLASS METHODS
  ##############################################################################

  def self.create_empty_checkins
    puts "Creating empty checkins"

    # Runs once an hour thanks to Clockwork and DelayedJob
    # This is necessary to catch all the different possible timezones

    Member.has_active_pair.each{|m|
      next unless m.local_time.hour == 0 # Run after midnight, locally
      m.pairs.active.each{|p|
        Checkin.create(member: m, pair: p)
      }
    }

  end


  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  # TODO: unit tests
  def mark_done
    self.done_at = Time.now
  end

  # TODO: unit tests
  def mark_done!
    self.done_at = Time.now
    save
  end

  # TODO: unit tests
  def mark_undone
    self.done_at = nil
  end

  # TODO: unit tests
  def mark_undone!
    mark_undone
    save
  end

  ##############################################################################
  # PRIVATE METHODS
  ##############################################################################

  private

  def set_defaults
    self.local_date ||= member.local_date if member
  end

end
