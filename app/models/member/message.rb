class Member::Message
  extend ActiveSupport::Concern
  attr_reader :member

  # Just a PORO that helps determine which message to send to members


  FIRST_TIME          = "first_time"
  SECOND_TIME         = "second_time"
  POST_SECOND_TIME    = "post_second_time"

  RESCHEDULE_HELPER   = "reschedule_helper"
  YES_RESPONSE_HELPER = "yes_response_helper"
  REMINDER_SIMUL_SAME = "reminder_simultaneous_same_activities"

  FIRST_INDEX  = 0
  SECOND_INDEX = 1

  SEEN_FNS = {
   RESCHEDULE_HELPER   => [:seen_first_helper_yes?, :seen_second_helper_yes?],
   YES_RESPONSE_HELPER => [:seen_first_helper_yes?, :seen_second_helper_yes?],
   REMINDER_SIMUL_SAME => [:seen_first_reminder?  , :seen_second_reminder?  ]
  }


  def initialize member
    @member = member
  end

  # TODO: unit tests
  def current_template_name t
    message_time = POST_SECOND_TIME
    message_base = t
    if !@member.send(SEEN_FNS[t][SECOND_INDEX])
      message_time = "first_time"
      message_time = "second_time" if @member.send(SEEN_FNS[t][FIRST_INDEX])
    end
    "#{message_base}_#{message_time}"
  end

  # TODO: unit tests
  def current_message_strings t, extras = nil
    Tandem::Message.message_strings current_template_name(t, extras)
  end


  # TODO: unit tests
  def current_reschedule_response_template_name
    current_template_name RESCHEDULE_HELPER
  end

  # TODO: unit tests
  def current_reschedule_response_messages extras = nil
    Tandem::Message.message_strings current_reschedule_response_template_name, extras
  end


  # TODO: unit tests
  def current_helper_yes_messages extras = nil
    Tandem::Message.message_strings current_helper_yes_template_name, extras
  end

  # TODO: unit tests
  def current_helper_yes_template_name
    current_template_name YES_RESPONSE_HELPER
  end

  # TODO: unit tests
  def current_reminder_messages extras = nil
    Tandem::Message.message_strings current_reminder_template_name, extras
  end

  # TODO: unit tests
  def current_reminder_template_name
    current_template_name REMINDER_SIMUL_SAME
  end

  # TODO: unit tests
  # TODO: move to member_message class
  def current_no_reply_message_strings

  end

  # TODO: unit tests
  # TODO: move to member_message class
  def current_no_reply_message_template_name
    message_time = "post_second_time"


    # TODO:
    # no_reply_both_first_time:
    # no_reply_both_post_second_time:
    # no_reply_both_second_time:
    # no_reply_doer:
    # no_reply_doer_first_time:
    # no_reply_doer_post_second_time:
    # no_reply_doer_second_time:
    # no_reply_helper:
    # no_reply_helper_first_time:
    # no_reply_helper_second_time:
    # no_reply_helper_post_second_time:
    # no_reply_simultaneous_different_activities:
    # no_reply_simultaneous_same_activities:


    if !member.seen_second_reminder?
      message_time = "first_time"
      message_time = "second_time" if member.seen_first_reminder?
    end
    "#{message_base}_#{message_time}"
  end








end
