# Controller for receiving SMS's
class SmsController < ApplicationController

  @@debug = true

  attr_accessor :message

  skip_before_action :verify_authenticity_token, only: [:receive]

  def receive
    return false unless (@@debug || valid_request?(params))

    tandem_number = Phoner::Phone.parse(params["To"]).to_s
    raise t("tandem.errors.no_from_number_provided") unless params["From"] # TODO: fix and internationalize

    member_number = Phoner::Phone.parse(params["From"]).to_s

    # Find the member based on their phone number
    # TODO: what if the same phone number is used for members who belong in multiple groups?
    member = Member.find_by(phone_number: member_number)

    return twiml(t("tandem.messages.phone_number_not_in_system")) unless member
    return twiml(t("tandem.messages.phone_number_unsubscribed")) if member.unsubscribed?

    # Find the pair, since they are uniquely identified by member_number, tandem_number
    pair = Pair.find_by_member_id_and_tandem_number(member.id, tandem_number)
    # return twiml(t("tandem.messages.pair_not_found", member_number: member_number, tandem_number: tandem_number)) unless pair
    return twiml(t("tandem.messages.pair_not_found")) unless pair

    # Get the date in the member's timezone
    local_date = member.local_date

    # Get the activity for the member from the pair
    activity   = pair.activity

    # Get the checkin
    checkin = member.checkins.find_by(pair_id: pair.id, local_date: local_date)

    # Parse the actual comment received
    body = params["Body"].strip

    # Save it to the database
    message = Sms.create( from: member, to: pair, message: body )

    if checkin
      return handle_yes(checkin) if matches_yes?(body)
      return handle_reschedule   if matches_reschedule?(body)
      return handle_am_pm        if matches_am_pm?(body)
    end
    return handle_unsubscribe if matches_unsubscribe?(body)
    handle_pass_through member, pair, body
  end

  private

  # TODO: unit tests
  def valid_request? params
    # TODO
    true
  end

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

  # TODO: unit tests
  def handle_reschedule
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
