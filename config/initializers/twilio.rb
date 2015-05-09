require "twilio-ruby"

class TwilioClient
  ACCOUNT_SID         = ENV["TWILIO_ACCOUNT_SID"]
  AUTH_TOKEN          = ENV["TWILIO_AUTH_TOKEN"]
  DEFAULT_FROM_NUMBER = ENV["TWILIO_DEFAULT_FROM_NUMBER"]

  @@the_client = Twilio::REST::Client.new ACCOUNT_SID, AUTH_TOKEN

  def self.sms to_number, message, from_number = nil
    from_number ||= DEFAULT_FROM_NUMBER
    @@the_client.messages.create(from: from_number, to: to_number, body: message)
  end
end
