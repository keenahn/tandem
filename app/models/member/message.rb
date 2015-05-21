class Member::Message
  extend ActiveSupport::Concern
  attr_reader :member

  def initialize member
    @member = member
  end

  # TODO: unit tests
  def current_reschedule_response_template_name
    message_time = "post_second_time"
    message_base = "reschedule_helper"
    if !@member.seen_second_helper_yes?
      message_time = "first_time"
      message_time = "second_time" if @member.seen_first_helper_reschedule?
    end
    "#{message_base}_#{message_time}"
  end

  # TODO: unit tests
  def current_helper_yes_template_name
    message_time = "post_second_time"
    message_base = "yes_response_helper"
    if !@member.seen_second_helper_yes?
      message_time = "first_time"
      message_time = "second_time" if @member.seen_first_helper_yes?
    end
    "#{message_base}_#{message_time}"
  end
end
