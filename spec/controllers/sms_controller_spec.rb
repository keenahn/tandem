require "spec_helper"

describe SmsController do
  describe "no checkin" do
    let(:p)        { FactoryGirl.create(:pair)   }
    let(:member_1) { p.member_1                  }
    let(:phone_1 ) { member_1.phone_number       }

    it "should raise error when no From number" do
      params = {
        "To" => TwilioClient::DEFAULT_FROM_NUMBER,
        "Body" => "TESTING NO FROM",
        "extra" => "Doesn't matter"
      }

      expect{ post(:receive, params) }.to raise_error
    end

    it "should return twiml phone_number_not_in_system when member not found" do
      params = {
        "From" => "9041038398210983",
        "To" => TwilioClient::DEFAULT_FROM_NUMBER,
        "Body" => "TESTING Bad number",
        "extra" => "Doesn't matter"
      }

      allow(controller).to receive(:render).with no_args
      expect(controller).to receive(:render).with({
        :partial => "twilio/message",
        :locals  => {msg: I18n.t("tandem.messages.phone_number_not_in_system")}
      })

      post :receive, params

      expect(response.status).to eq(200)
    end

    it "should return twiml phone_number_unsubscribed when member unsubscribed" do
      member_1.unsubscribe!

      params = {
        "From" => phone_1,
        "To" => TwilioClient::DEFAULT_FROM_NUMBER,
        "Body" => "TESTING PASS THROUGH",
        "extra" => "Doesn't matter"
      }

      allow(controller).to receive(:render).with no_args
      expect(controller).to receive(:render).with({
        :partial => "twilio/message",
        :locals  => {msg: I18n.t("tandem.messages.phone_number_unsubscribed")}
      })

      post :receive, params

      expect(response.status).to eq(200)
    end

    it "should return twiml pair_not_found when pair not found" do
      member_3 = FactoryGirl.create(:member)
      params = {
        "From" => member_3.phone_number,
        "To" => TwilioClient::DEFAULT_FROM_NUMBER,
        "Body" => "TESTING PASS THROUGH",
        "extra" => "Doesn't matter"
      }

      allow(controller).to receive(:render).with no_args
      expect(controller).to receive(:render).with({
        :partial => "twilio/message",
        :locals  => {msg: I18n.t("tandem.messages.pair_not_found")}
      })

      post :receive, params

      expect(response.status).to eq(200)
    end

    it "should pass through" do
      params = {
        "From"  => phone_1,
        "To"    => TwilioClient::DEFAULT_FROM_NUMBER,
        "Body"  => "TESTING PASS THROUGH",
        "extra" => "Doesn't matter"
      }

      # expect(Sms).to receive(:create)

      post :receive, params

      expect(response.status).to eq(200)
    end
  end

  describe "with checkin" do
    let(:pair)     { FactoryGirl.create(:pair)   }
    let(:member)   { pair.member_1               }

    it "should handle_yes when matches_yes? yes" do
      params = {
        "From"  => member.phone_number,
        "To"    => pair.tandem_number,
        "Body"  => "Yes, doing it now!",
        "extra" => "Doesn't matter"
      }

      checkin = FactoryGirl.create(:checkin, pair: pair, member: member)

      allow(controller).to receive(:handle_yes).with no_args
      expect(controller).to receive(:handle_yes).and_call_original

      post(:receive, params)

      expect(response.status).to eq(200)
    end



  end


end
