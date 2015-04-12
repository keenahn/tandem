class SendSmsJob < ActiveJob::Base
  queue_as :default

  def perform sms
    sms.send_sms
  end
end
