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
    return twiml(Tandem::Message.message_string("phone_number_not_in_system")) unless member
    return twiml(Tandem::Message.message_string("phone_number_unsubscribed")) if member.unsubscribed?

    # Find the pair, since they are uniquely identified by member_id, tandem_number
    pair = Pair.find_by_member_id_and_tandem_number(member.id, tandem_number)
    return twiml(Tandem::Message.message_string("pair_not_found")) unless pair

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
    body = "#{other_member.first_name}: #{body}"
    p = { from: member, to: other_member, message: body }
    Sms.create_and_send(p)
    render_nothing
  end

  # TODO: unit tests
  def handle_yes checkin
    return twiml(Tandem::Message.message_string("yes_again_response_doer")) if checkin.done?
    checkin.mark_done!                # Mark checkin as checked in
    send_yes_response_doer(checkin)   # Alert doer
    send_yes_response_helper(checkin) # Alert helper
    render_nothing
  end

  # TODO: unit tests
  def send_yes_response_doer checkin
    # TODO: move this logic of which message to member_message class
    doer_message = Tandem::Message.message_string("yes_response_doer", yes_response_args(checkin))
    member = checkin.member
    Sms.create_and_send(from: checkin.pair, to: member, message: doer_message)
    member.increment_doer_yes_count!
  end

  # TODO: unit tests
  # TODO: move elsewhere?
  def yes_response_args checkin
    doer                = checkin.member
    helper              = checkin.other_member
    doer_first_name     = doer.first_name
    helper_first_name   = helper.first_name
    activity_args       = Tandem::Message.activity_tenses(checkin.activity)
    doer_pronoun_object = Tandem::Message.gender_pronouns(doer.gender)[:pronoun_object]
    ret = activity_args.merge(
      doer_first_name: doer_first_name,
      helper_first_name: helper_first_name,
      doer_pronoun_object: doer_pronoun_object
    )
    ret
  end

  # TODO: unit tests
  def send_yes_response_helper checkin
    helper = checkin.other_member
    member_message = Member::Message.new(helper)
    helper_messages = member_message.current_helper_yes_messages(yes_response_args(checkin))
    Sms.create_and_send(from: checkin.pair, to: helper, message: helper_messages)
    helper.increment_helper_yes_count!
  end

  def get_reschedule_time reschedule_time_string, pair
    local_date_string = pair.local_date.strftime(Tandem::Consts::DEFAULT_DATE_FORMAT)
    reschedule_time_string = "#{local_date_string} #{reschedule_time_string}"
    Tandem::Utils.parse_time_in_zone(reschedule_time_string, pair.time_zone)
  end

  # TODO: unit tests
  # TODO: split up more?
  def handle_reschedule checkin, body
    reschedule_time_string = extract_time(body)
    return twiml(Tandem::Message.message_string("bad_time")) unless reschedule_time_string

    pair = checkin.pair
    reschedule_time = get_reschedule_time(reschedule_time_string, pair)
    return twiml(Tandem::Message.message_string("bad_time")) unless reschedule_time

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
      return twiml(Tandem::Message.message_string("reschedule_too_late"))
    end

    # If meridiem is not set, could be one of two times
    # Without the meridiem suffix, it will be interpreted as AM
    if local_time > reschedule_time
      # When interpreted as AM, the time is past, so try it with forced PM
      reschedule_time_string += " PM"
      reschedule_time = get_reschedule_time(reschedule_time_string, pair)

      # Rescheduling when forcing PM is also after current time, so they gave an impossible time
      return twiml(Tandem::Message.message_string("reschedule_too_late")) if local_time > reschedule_time

      # e.g. The user wants to reschedule for 1:30. It is currently 9:30AM.
      # This will reschedule for 1:30 PM
      return reschedule_and_notify(checkin, reschedule_time)
    else
      # reschedule time is ambiguous so ask for clarification
      reminder = checkin.reminder
      reminder.temp_reschedule(reschedule_time)
      return twiml(Tandem::Message.message_string("am_or_pm"))
    end

  end # close handle_reschedule


  # TODO: unit tests
  def reschedule_and_notify checkin, reschedule_time
    reminder = checkin.reminder
    reminder.reschedule(reschedule_time)
    send_reschedule_response_doer(checkin, reschedule_time)
    send_reschedule_response_helper(checkin, reschedule_time)
    render_nothing
  end

  # TODO: unit tests
  def send_reschedule_response_doer checkin, reschedule_time
    member = checkin.member
    # TODO: move this logic of which message to member_message class
    reschedule_args = reschedule_response_args(checkin, reschedule_time)
    doer_message = Tandem::Message.message_string("reschedule_doer", reschedule_args)
    Sms.create_and_send(from: checkin.pair, to: member, message: doer_message)
    member.increment_doer_reschedule_count!
  end

  # TODO: unit tests
  def send_reschedule_response_helper checkin, reschedule_time
    partner = checkin.other_member
    member_message = Member::Message.new(partner)
    reschedule_args = reschedule_response_args(checkin, reschedule_time)
    helper_message = member_message.current_reschedule_response_messages(reschedule_args)
    Sms.create_and_send(from: checkin.pair, to: partner, message: helper_message)
    partner.increment_helper_reschedule_count!
  end

  # TODO: unit tests
  def reschedule_response_args checkin, reschedule_time
    reschedule_time         = Tandem::Utils.short_time(reschedule_time)
    doer                    = checkin.member
    helper                  = checkin.other_member
    doer_first_name         = doer.first_name
    helper_first_name       = helper.first_name
    activity_args           = Tandem::Message.activity_tenses(checkin.activity)
    doer_pronouns           = Tandem::Message.gender_pronouns(doer.gender)
    doer_pronoun_object     = doer_pronouns[:pronoun_object]
    doer_pronoun_possessive = doer_pronouns[:pronoun_possessive]

    ret = activity_args.merge(
      doer_first_name:         doer_first_name,
      helper_first_name:       helper_first_name,
      doer_pronoun_object:     doer_pronoun_object,
      doer_pronoun_possessive: doer_pronoun_possessive,
      reschedule_time:         reschedule_time
    )
    ret
  end

  # TODO: unit tests
  def handle_am_pm
    # TODO! Make work!
  end

  # TODO: unit tests
  def handle_unsubscribe
    # TODO
    # Unsubscribe the member
    # Deactivate the pair
    # Alert the partner
  end

  # TODO: unit tests
  def extract_time s
    time_pattern = /\b([0-9]|0[0-9]|1?[0-9]|2[0-3]):[0-5][0-9]/i # matches time 10:23 and similar
    return time_pattern.match(s)[0] if time_pattern.match(s)
    nil
  end

  # TODO: unit tests
  def extract_am_pm s
    # TODO! Make work
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
