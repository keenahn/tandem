# Controller for receiving SMS's
class SmsController < ApplicationController

  @@debug = false

  attr_accessor :message

  def receive
    return false unless (@@debug || TandemSms.valid_request?(params))

    tandem_number = params["To"][-10..10]
    raise t("tandem.errors.no_from_number_provided") unless params["From"] # TODO: fix and internationalize

    member_number = params["From"][-10..10]

    # Find the member based on their phone number
    # TODO: what if the same phone number is used for members who belong in multiple groups?
    member = Member.find_by_phone_number(member_number)
    return TandemSms.twiml(t("tandem.messages.phone_number_not_in_system", member_number: member_number)) unless member
    return TandemSms.twiml(t("tandem.messages.phone_number_unsubscribed", member_number: member_number)) if member.unsubscribed?

    # Find the pair, since they are uniquely identified by member_number, tandem_number
    pair   = Pair.find_by_member_and_tandem_number(member_number, tandem_number)
    return TandemSms.twiml(t("tandem.messages.pair_not_found", member_number: member_number, tandem_number: tandem_number)) unless pair

    # Get the date in the member's timezone
    local_date = member.local_date

    # Get the activity for the member from the pair
    activity   = pair.get_activity(member)

    # checkin exists, or it's a one way relationship, and the message was received
    # from the helper
    checkin = member.checkins.find_by_activity_and_local_date(activity, local_date)

    # Parse the actual comment received
    body = params["Body"].strip
    parsed_body = TandemParser.parse(body)

    # Save it to the database
    message = Sms.create(from_number: member_number, to_number: tandem_number, body: body)

    # get the other member
    partner = pair.get_partner(member)

    if checkin
      return handle_yes if parsed_body.matches_yes?
      return handle_reschedule if parsed_body.matches_reschedule?
      return handle_am_pm if parsed_body.matches_am_pm?
    end
    return handle_unsubscribe if parsed_body.matches_unsubscribe?
    handle_pass_through
  end


    render nothing: true, status: 200, content_type: "text/html"
  end

end # close TwilioController
