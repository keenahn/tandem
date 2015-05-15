# Controller for receiving SMS's
class SmsController < ApplicationController

  @@debug = true

  attr_accessor :message

  skip_before_action :verify_authenticity_token, only: [:receive]

  def receive
    tandem_number = Phoner::Phone.parse(params["To"]).to_s
    raise t("tandem.errors.no_from_number_provided") unless params["From"] # TODO: fix and internationalize

    # Find the member based on their phone number
    # TODO: what if the same phone number is used for members who belong in multiple groups?
    member_number = Phoner::Phone.parse(params["From"]).to_s
    member = Member.find_by(phone_number: member_number)
    return twiml(t("tandem.messages.phone_number_not_in_system")) unless member
    return twiml(t("tandem.messages.phone_number_unsubscribed")) if member.unsubscribed?

    # Find the pair, since they are uniquely identified by member_id, tandem_number
    pair = Pair.find_by_member_id_and_tandem_number(member.id, tandem_number)
    return twiml(t("tandem.messages.pair_not_found")) unless pair

    local_date = member.local_date   # Get the date in the member's timezone
    activity   = pair.activity       # Get the activity for the member from the pair

    # Get the checkin
    checkin = Checkin.find_by(member_id: member.id, pair_id: pair.id, local_date: local_date)

    # Save it to the database
    body = params["Body"].strip
    message = Sms.create(from: member, to: pair, message: body)

    if checkin
      return handle_yes(checkin)              if matches_yes?(body)
      return handle_reschedule(checkin, body) if matches_reschedule?(body)
      return handle_am_pm                     if matches_am_pm?(body)
    end
    return handle_unsubscribe if matches_unsubscribe?(body)
    handle_pass_through member, pair, body
  end

  private

  def twiml msg
    render partial: "twilio/message", locals: {msg: msg}
  end

  def render_nothing
    render nothing: true, status: 200, content_type: "text/html"
  end

  def handle_pass_through member, pair, body
    other_member = pair.other_member(member)
    p = { from: member, to: other_member, message: body }
    Sms.create_and_send(p)
    render_nothing
  end

  # TODO: unit tests
  def handle_yes checkin
    return twiml(t("tandem.messages.yes_again_response_doer")) if checkin.done?
    checkin.mark_done!                # Mark checkin as checked in
    send_yes_response_doer(checkin)   # Alert doer
    send_yes_response_helper(checkin) # Alert helper
    render_nothing
  end

  # TODO: unit tests
  def send_yes_response_doer checkin
    # TODO: move this logic of which message to member_message class
    doer_message = t("tandem.messages.yes_response_doer").sample
    Sms.create_and_send(from: checkin.pair, to: checkin.member, message: doer_message)
    member.increment_doer_yes_count!
  end

  # TODO: unit tests
  def send_yes_response_helper checkin
    partner = checkin.other_member
    # TODO: move this logic of which message to member_message class
    helper_message = t("tandem.messages.#{current_helper_yes_template_name(partner)}")
    Sms.create_and_send(from: checkin.pair, to: partner, message: helper_message)
    partner.increment_helper_yes_count!
  end

  # TODO: unit tests
  # TODO: move to member_message class
  def current_helper_yes_template_name partner
    message_time = "post_second_time"
    message_base = "yes_response_helper"
    if !partner.seen_second_helper_yes?
      message_time = "first_time"
      message_time = "second_time" if partner.seen_first_helper_yes?
    end
    "#{message_base}_#{message_time}"
  end

  def get_reschedule_time reschedule_time_string, pair
    local_date_string = pair.local_date.strftime(Tandem::Consts::DEFAULT_DATE_FORMAT)
    reschedule_time_string = "#{local_date_string} #{reschedule_time_string}"
    Tandem::Utils.parse_time_in_zone(reschedule_time_string, pair.time_zone)
  end

  # TODO: unit tests
  def handle_reschedule checkin, body
    reschedule_time_string = extract_time(body)
    return twiml(t("tandem.messages.bad_time")) unless reschedule_time_string

    pair = checkin.pair
    reschedule_time = get_reschedule_time(reschedule_time_string, pair)
    return twiml(t("tandem.messages.bad_time")) unless reschedule_time

    # This is the most complex part of this function, and it's not easily refactored
    hour = reschedule_time.strftime("%H").to_i
    body_down = body.downcase.strip
    if hour <= 12
      if body_down.include?("p")
        reschedule_time_string += " PM"
      elsif body_down.include?("a")
        reschedule_time_string += " AM"
      end
      meridiem_set = body_down.include?("a") || body_down.include?("p")
      reschedule_time = get_reschedule_time(reschedule_time_string, pair) if meridiem_set
    else
      meridiem_set = true
    end

    local_time = pair.local_time

    if meridiem_set
      return reschedule_and_notify(checkin, reschedule_time) if local_time < reschedule_time
      return twiml(t("tandem.messages.reschedule_too_late"))
    end

    # If meridiem is not set, could be one of two times
    # Without the meridiem suffix, it will be interpreted as AM
    if local_time > reschedule_time
      # When interpreted as AM, the time is past, so try it with forced PM
      reschedule_time_string += " PM"
      reschedule_time = get_reschedule_time(reschedule_time_string, pair)

      # Rescheduling when forcing PM is also after current time, so they gave an impossible time
      return twiml(t("tandem.messages.reschedule_too_late")) if local_time > reschedule_time

      # e.g. The user wants to reschedule for 1:30. It is currently 9:30AM.
      # This will reschedule for 1:30 PM
      return reschedule_and_notify(checkin, reschedule_time)
    else
      # reschedule time is ambiguous so ask for clarification
      reminder = checkin.reminder
      reminder.temp_reschedule(reschedule_time)
      return twiml(t("tandem.messages.am_or_pm"))
    end

  end # close handle_reschedule


  # TODO: unit tests
  # TODO
  def reschedule_and_notify checkin, reschedule_time
    reminder = checkin.reminder
    reminder.reschedule(reschedule_time)
    send_reschedule_response_doer(checkin)
    send_reschedule_response_helper(checkin)
    render_nothing
  end

  # TODO: unit tests
  def send_reschedule_response_doer checkin
    member = checkin.member
    # TODO: move this logic of which message to member_message class
    doer_message = t("tandem.messages.reschedule_doer").sample
    Sms.create_and_send(from: checkin.pair, to: member, message: doer_message)
    member.increment_doer_reschedule_count!
  end

  # TODO: unit tests
  def send_reschedule_response_helper checkin
    partner = checkin.other_member
    # TODO: move this logic of which message to member_message class
    helper_message = t("tandem.messages.#{current_reschedule_response_template_name(partner)}")
    Sms.create_and_send(from: checkin.pair, to: partner, message: helper_message)
    partner.increment_helper_reschedule_count!
  end

  # TODO: unit tests
  # TODO: move to member_message class
  def current_reschedule_response_template_name partner
    message_time = "post_second_time"
    message_base = "reschedule_helper"
    if !partner.seen_second_helper_yes?
      message_time = "first_time"
      message_time = "second_time" if partner.seen_first_helper_reschedule?
    end
    "#{message_base}_#{message_time}"
  end


  # TODO: unit tests
  def handle_am_pm
  end

  # TODO: unit tests
  def handle_unsubscribe
    # TODO
    # Unsubscribe the member
    # Deactivate the pair
    # Alert the partner
  end

  def extract_time s
    time_pattern = /\b([0-9]|0[0-9]|1?[0-9]|2[0-3]):[0-5][0-9]/i # matches time 10:23 and similar
    return time_pattern.match(s)[0] if time_pattern.match(s)
    nil
  end

  def extract_am_pm s

  end


  # TODO: unit tests
  def matches_yes? s
    /\b(yes|yeah|ok)/i =~ s ? true : false
  end

  # TODO: unit tests
  def matches_reschedule? s
    /\bresched/i =~ s ? true : false
  end

  # TODO: unit tests
  def matches_am_pm? s
    /(\b(am|pm)\b|\b(a\.m\.|p\.m\.))/i =~ s ? true : false
  end

  # TODO: unit tests
  def matches_unsubscribe? s
    /\b(unsub)|^STOP$|^REMOVE$/i =~ s ? true : false
  end


end # close SmsController
