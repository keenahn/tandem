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
    @member = Member.find_by(phone_number: member_number)

    return twiml(t("tandem.messages.phone_number_not_in_system")) unless @member
    return twiml(t("tandem.messages.phone_number_unsubscribed")) if @member.unsubscribed?

    # Find the pair, since they are uniquely identified by member_number, tandem_number
    @pair = Pair.find_by_member_id_and_tandem_number(@member.id, tandem_number)
    # return twiml(t("tandem.messages.pair_not_found", member_number: member_number, tandem_number: tandem_number)) unless @pair
    return twiml(t("tandem.messages.pair_not_found")) unless @pair
    return handle_pass_through @member, @pair, params["Body"]



    # TODO: rest of the logic




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

    render nothing: true, status: 200, content_type: "text/html"
  end

  # Just testing. It works!
  # def index
  #   twiml("Hello World")
  # end

  private

  # TODO: unit tests
  def valid_request? params
    # TODO
    true
  end

  def twiml msg
    render partial: "twilio/message", locals: {msg: msg}
  end

  def handle_pass_through member, pair, body
    other_member = pair.other_member(member)

    p = {
      from: member,
      to: other_member,
      message: body
    }

    # puts p

    Sms.create(p)
    render nothing: true, status: 200, content_type: "text/html"
  end

end # close SmsController
