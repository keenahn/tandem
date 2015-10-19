class Member::Message
  extend ActiveSupport::Concern
  attr_reader :member

  # Just a PORO that helps determine which message to send to members
  FIRST_TIME       = "first_time"
  SECOND_TIME      = "second_time"
  POST_SECOND_TIME = "post_second_time"

  RESCHEDULE_HELPER       = "reschedule_helper"
  YES_RESPONSE_HELPER     = "yes_response_helper"
  REMINDER_SIMUL_SAME     = "reminder_simultaneous_same_activities"
  REMINDER_ONE_WAY_DOER   = "reminder_one_way_doer"
  REMINDER_ONE_WAY_HELPER = "reminder_one_way_helper"

  NO_REPLY_DOER   = "no_reply_doer"
  NO_REPLY_HELPER = "no_reply_helper"
  NO_REPLY_BOTH   = "no_reply_both"

  FIRST_INDEX  = 0
  SECOND_INDEX = 1

  SEEN_FNS = {
    RESCHEDULE_HELPER       => [:seen_first_helper_reschedule? , :seen_second_helper_reschedule? ],
    YES_RESPONSE_HELPER     => [:seen_first_helper_yes?        , :seen_second_helper_yes?        ],
    REMINDER_SIMUL_SAME     => [:seen_first_reminder?          , :seen_second_reminder?          ],
    REMINDER_ONE_WAY_DOER   => [:seen_first_reminder?          , :seen_second_reminder?          ],
    REMINDER_ONE_WAY_HELPER => [:seen_first_other_reminder?    , :seen_second_other_reminder?    ],
    NO_REPLY_DOER           => [:seen_first_doer_no_reply?     , :seen_second_doer_no_reply?     ],
    NO_REPLY_HELPER         => [:seen_first_helper_no_reply?   , :seen_second_helper_no_reply?   ],
    NO_REPLY_BOTH           => [:seen_first_both_no_reply?     , :seen_second_both_no_reply?     ],
  }


  def initialize member
    @member = member
  end

  def current_template_name t
    message_time = POST_SECOND_TIME
    message_base = t
    if !@member.send(SEEN_FNS[t][SECOND_INDEX])
      message_time = FIRST_TIME
      message_time = SECOND_TIME if @member.send(SEEN_FNS[t][FIRST_INDEX])
    end
    "#{message_base}_#{message_time}"
  end

  # TODO: unit tests
  def current_message_strings t, extras = nil
    Tandem::Message.message_strings current_template_name(t), extras
  end

  # TODO: unit tests
  def current_reschedule_response_messages extras = nil
    current_message_strings RESCHEDULE_HELPER, extras
  end

  # TODO: unit tests
  def current_helper_yes_messages extras = nil
    current_message_strings YES_RESPONSE_HELPER, extras
  end

  # TODO: unit tests
  def current_reminder_messages extras = nil
    current_message_strings REMINDER_SIMUL_SAME, extras
  end

  # TODO: unit tests
  def current_helper_reminder_messages extras = nil
    current_message_strings REMINDER_ONE_WAY_HELPER, extras
  end

  # TODO: unit tests
  def current_doer_reminder_messages extras = nil
    current_message_strings REMINDER_ONE_WAY_DOER, extras
  end

  # TODO: unit tests
  def current_doer_no_reply_messages extras = nil
    current_message_strings NO_REPLY_DOER, extras
  end

  # TODO: unit tests
  def current_helper_no_reply_messages extras = nil
    current_message_strings NO_REPLY_HELPER, extras
  end

  # TODO: unit tests
  def current_both_no_reply_messages extras = nil
    current_message_strings NO_REPLY_BOTH, extras
  end

end
