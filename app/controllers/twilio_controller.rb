class TwilioController < ApplicationController
  def receive
    # Rails.logger.info params.inspect
    u = User.find_by_phone_number params["From"]
    return false if(!u || u.id == User::PIGGYBACKR_ADMIN_ID)
    return false unless u.fundraisers.count > 0
    fundraiser = u.fundraisers.first
    s = Sms.new({
      team_fundraiser_id: fundraiser.team.id,
      from_id: u.id,
      to_id: User::PIGGYBACKR_ADMIN_ID,
      message: params["Body"],
      category: Sms::INCOMING
    })
    s.save

    body = params["Body"].strip.downcase
    if body == "stop" || body == "unsubscribe"
      if !fundraiser.enable_sms
        # # This calls send, too
        # s = Sms.new({
        #   team_fundraiser_id: fundraiser.team.id,
        #   from_id: User::PIGGYBACKR_ADMIN_ID,
        #   to_id: u.id,
        #   message: render_to_string("sms/already_unsubscribed", formats: [:text], locals: {fundraiser: fundraiser}),
        #   category: Sms::ALREADY_UNSUBSCRIBED
        # })

        # s.save!
      else
        # This calls send, too
        s = Sms.new({
          team_fundraiser_id: fundraiser.team.id,
          from_id: User::PIGGYBACKR_ADMIN_ID,
          to_id: u.id,
          message: render_to_string("sms/unsubscribed", formats: [:text], locals: {fundraiser: fundraiser}),
          category: Sms::UNSUBSCRIBE
        })

        s.save!
      end
      u.fundraisers.update_all(enable_sms: false)

      return render nothing: true, status: 200, content_type: 'text/html'
    else

      UtilityMailer.incoming_sms(u.id, params).deliver

      # Do nothing, for now

      # s = Sms.new({
      #   team_fundraiser_id: fundraiser.team.id,
      #   from_id: User::PIGGYBACKR_ADMIN_ID,
      #   to_id: u.id,
      #   message: render_to_string("sms/unknown_command", formats: [:text], locals: {fundraiser: fundraiser}),
      #   category: Sms::UNKNOWN_COMMAND
      # })

      # s.save!
    end
    render nothing: true, status: 200, content_type: 'text/html'
  end

end # close TwilioController
