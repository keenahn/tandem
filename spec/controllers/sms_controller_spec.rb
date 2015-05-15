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

  describe "should reschedule" do
    before :each do
      @pair = FactoryGirl.create(:pair)
      @member = @pair.member_1
      @pair.set_all_reminder_times "09:00"
      @pair.save
      @checkin  = FactoryGirl.create(:checkin, pair: @pair, member: @member, local_date: @pair.local_date)
      @reminder = @checkin.create_or_update_reminder

      @local_date_string = @pair.local_date.strftime(Tandem::Consts::DEFAULT_DATE_FORMAT)
      @local_midnight = Tandem::Utils.parse_time_in_zone("#{@local_date_string} 00:00", @pair.time_zone)
      @local_1330 = Tandem::Utils.parse_time_in_zone("#{@local_date_string} 13:30", @pair.time_zone)
      @params = {
        "From"  => @member.phone_number,
        "To"    => @pair.tandem_number,
        "Body"  => "resched",
        "extra" => "Doesn't matter"
      }

    end

    describe "valid" do
      ["13:00", "9:30 AM", "9:30 PM"].each do |t|
        it "valid time: #{t}" do
          # Time travel to 12:30 AM
          Timecop.travel(@local_midnight + 30.minute) do
            @params["Body"] = "resched #{t}"

            allow(controller).to receive(:handle_reschedule).with no_args
            expect(controller).to receive(:handle_reschedule).and_call_original

            allow(controller).to receive(:reschedule_and_notify).with no_args
            expect(controller).to receive(:reschedule_and_notify).and_call_original

            post(:receive, @params)

            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe "valid (afternoon)" do
      ["5:00"].each do |t|
        it "valid time: #{t}" do
          # Time travel to 12:30 AM
          Timecop.travel(@local_1330) do
            @params["Body"] = "resched #{t}"

            allow(controller).to receive(:handle_reschedule).with no_args
            expect(controller).to receive(:handle_reschedule).and_call_original

            allow(controller).to receive(:reschedule_and_notify).with no_args
            expect(controller).to receive(:reschedule_and_notify).and_call_original

            post(:receive, @params)

            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe "invalid" do
      ["25:00", "asdf", "12:98 PM"].each do |t|
        it "invalid time: #{t}" do
          # Time travel to 12:30 AM
          Timecop.travel(@local_midnight + 30.minute) do
            @params["Body"] = "resched #{t}"

            allow(controller).to receive(:handle_reschedule).with no_args
            expect(controller).to receive(:handle_reschedule).and_call_original

            allow(controller).to receive(:render).with no_args
            expect(controller).to receive(:render).with({
              :partial => "twilio/message",
              :locals  => {msg: I18n.t("tandem.messages.bad_time")}
            })

            post(:receive, @params)

            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe "ambiguous" do
      ["5:00", "11:00"].each do |t|
        it "ambiguous time: #{t}" do
          # Time travel to 12:30 AM
          Timecop.travel(@local_midnight + 30.minute) do
            @params["Body"] = "resched #{t}"

            allow(controller).to receive(:handle_reschedule).with no_args
            expect(controller).to receive(:handle_reschedule).and_call_original

            allow(controller).to receive(:render).with no_args
            expect(controller).to receive(:render).with({
              :partial => "twilio/message",
              :locals  => {msg: I18n.t("tandem.messages.am_or_pm")}
            })

            post(:receive, @params)

            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe "already past" do
      ["12:00", "13:00", "1:00", "05:00 AM"].each do |t|
        it "already past time: #{t}" do
          # Time travel to 12:30 AM
          Timecop.travel(@local_1330) do
            @params["Body"] = "resched #{t}"

            allow(controller).to receive(:handle_reschedule).with no_args
            expect(controller).to receive(:handle_reschedule).and_call_original

            allow(controller).to receive(:render).with no_args
            expect(controller).to receive(:render).with({
              :partial => "twilio/message",
              :locals  => {msg: I18n.t("tandem.messages.reschedule_too_late")}
            })

            post(:receive, @params)

            expect(response.status).to eq(200)
          end
        end
      end
    end

  end


end
