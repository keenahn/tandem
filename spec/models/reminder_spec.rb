require "spec_helper"

RSpec.describe Reminder, type: :model do

  it { should belong_to(:member) }
  it { should belong_to(:pair) }
  it { should have_one(:group).through(:pair) }

  [:member, :pair].each do |f|
    it { should validate_presence_of(f) }
  end

  describe "tests" do
    before :each do
      @m = FactoryGirl.create(:member)
      @pair_1 = FactoryGirl.create(:pair, {member_1: @m})
      @pair_2 = FactoryGirl.create(:pair, {member_2: @m})

      tnow = Time.now.in_time_zone(@pair_1.group.time_zone) - Reminder::DEFAULT_WINDOW.minute + 1.minute

      pair_args = {
        reminder_time_mon:  tnow.strftime(Tandem::Consts::SHORT_TIME_24_FORMAT),
        reminder_time_tue:  tnow.strftime(Tandem::Consts::SHORT_TIME_24_FORMAT),
        reminder_time_wed:  tnow.strftime(Tandem::Consts::SHORT_TIME_24_FORMAT),
        reminder_time_thu:  tnow.strftime(Tandem::Consts::SHORT_TIME_24_FORMAT),
        reminder_time_fri:  tnow.strftime(Tandem::Consts::SHORT_TIME_24_FORMAT),
        reminder_time_sat:  tnow.strftime(Tandem::Consts::SHORT_TIME_24_FORMAT),
        reminder_time_sun:  tnow.strftime(Tandem::Consts::SHORT_TIME_24_FORMAT)
      }

      @pair_1.update_attributes(pair_args)
      @pair_2.update_attributes(pair_args)

      @inactive_pair = FactoryGirl.create(:pair,  pair_args.merge(member_2: @m, active: false))
      @pair_ids = @m.pairs.pluck(:id).sort

      [@pair_1, @pair_2].each {|p|
        p.members.each{|m|
          c = Checkin.find_or_initialize_by(member: m, pair: p, local_date: m.local_date)
          c.save
          c.create_or_update_reminder
        }
      }

      @r = Reminder.find_by(pair_id: @pair_1.id, member_id: @m.id)
      @r2 = Reminder.where(pair_id: @pair_1.id).where("member_id <> ?", @m.id).first
      @r3 = Reminder.find_by(pair_id: @pair_2.id, member_id: @m.id)
      @r4 = Reminder.where(pair_id: @pair_2.id).where("member_id <> ?", @m.id).first
      # TODO: move some of this stuff to a reminder_factory
    end

    it "sent reminders when time was correct" do
      unsent_count_1 = Reminder.unsent.count
      sent_count_1   = Reminder.sent.count

      Reminder.send_reminders
      unsent_count_2 = Reminder.unsent.count
      sent_count_2   = Reminder.sent.count

      expect(unsent_count_2).to equal(unsent_count_1 - 4)
      expect(sent_count_2).to equal(sent_count_1 + 4)
    end

    it "sent one way reminders when one member was done" do
      @m.checkins.update_all(done_at: Time.now - 5.minute)
      unsent_count_1 = Reminder.unsent.count
      sent_count_1   = Reminder.sent.count

      Reminder.send_reminders

      @r  = Reminder.find @r.id
      @r2 = Reminder.find @r2.id
      @r3 = Reminder.find @r3.id
      @r4 = Reminder.find @r4.id

      # puts @r
      # puts @r2
      # puts @r3
      # puts @r4

      unsent_count_2 = Reminder.unsent.count
      sent_count_2   = Reminder.sent.count

      expect(unsent_count_2).to equal(unsent_count_1 - 2)
      expect(sent_count_2).to equal(sent_count_1 + 2)
    end

    it "sent one way reminders when one member rescheduled" do
      @m.reminders.update_all(next_reminder_time_utc: Time.now + 2.hour)

      unsent_count_1 = Reminder.unsent.count
      sent_count_1   = Reminder.sent.count

      Reminder.send_reminders

      @r  = Reminder.find @r.id
      @r2 = Reminder.find @r2.id
      @r3 = Reminder.find @r3.id
      @r4 = Reminder.find @r4.id

      puts @r
      puts @r2
      puts @r3
      puts @r4

      # puts Reminder.unsent.inspect
      # puts Reminder.sent.inspect

      unsent_count_2 = Reminder.unsent.count
      sent_count_2   = Reminder.sent.count

      expect(unsent_count_2).to equal(unsent_count_1 - 2)
      expect(sent_count_2).to equal(sent_count_1 + 2)
    end

    it "did not send reminders when time was correct" do
      Timecop.travel(Time.now + 20.minute)

      unsent_count_1 = Reminder.unsent.count
      sent_count_1   = Reminder.sent.count

      Reminder.send_reminders

      unsent_count_2 = Reminder.unsent.count
      sent_count_2   = Reminder.sent.count

      expect(unsent_count_2).to equal(unsent_count_1)
      expect(sent_count_2).to equal(sent_count_1)
      Timecop.return
    end

    it "activity_args" do
      act_args = {
        activity_infinitive: "to meditate",
        activity_noun: "meditation",
        activity_noun_cap: "Meditation",
        activity_past: "meditated",
        activity_present_participle: "meditating",
        activity_short_noun: "'tate",
        activity_simple_present: "meditate",
        activity_simple_present_cap: "Meditate"
      }

      @pair_1.activity = "meditation"
      @pair_1.save

      expect(@r.activity_args).to eq(act_args)
    end

    it "mark_sent" do
      @r.status = :unsent
      @r.last_reminder_time_utc = nil
      @r.save
      @r.mark_sent
      expect(@r.status).to eq("sent")
      expect(@r.last_reminder_time_utc).not_to be_nil
    end

    it "mark_sent!" do
      @r.status = :unsent
      @r.last_reminder_time_utc = nil
      @r.save

      expect(@r.status).to eq("unsent")
      expect(@r.last_reminder_time_utc).to be_nil

      @r.mark_sent!
      @r = Reminder.find_by(pair_id: @pair_1.id, member_id: @m.id)
      expect(@r.status).to eq("sent")
      expect(@r.last_reminder_time_utc).not_to be_nil
    end

    it "reschedule" do
      @r.status = :sent
      @r.next_reminder_time_utc = nil
      @r.save

      t = (Time.now + 11.hour + 12.minute).utc
      @r.reschedule t
      @r = Reminder.find_by(pair_id: @pair_1.id, member_id: @m.id)

      expect(@r.status).to eq("unsent")
      expect(@r.next_reminder_time_utc.to_i).to be_within(1).of(t.to_i)
      expect(@r.last_reminder_time_utc).to be_nil
    end

    it "temp_reschedule" do
      @r.status = :sent
      @r.temp_reschedule_time_utc = nil
      @r.save

      t = (Time.now + 11.hour + 12.minute).utc
      @r.temp_reschedule t
      @r = Reminder.find_by(pair_id: @pair_1.id, member_id: @m.id)

      expect(@r.status).to eq("unsent")
      expect(@r.temp_reschedule_time_utc.to_i).to be_within(1).of(t.to_i)
    end

    it "checkin" do
      c = Checkin.find_by(pair_id: @pair_1.id, member_id: @m.id, local_date: @m.local_date)
      expect(@r.checkin).to eq(c)
    end

    it "checkin_done?" do
      c = Checkin.find_by(pair_id: @pair_1.id, member_id: @m.id, local_date: @m.local_date)
      c.mark_done!
      expect(@r.checkin_done?).to be(true)

      c.mark_undone!
      expect(@r.checkin_done?).to be(false)
    end

    it "send_sms" do
      message_strings = ["a", "b", "c"]
      args = {
        from:    @r.pair,
        to:      @r.member,
        message: message_strings
      }

      allow(Sms).to receive(:create_and_send).with args
      expect(Sms).to receive(:create_and_send).with args

      @r.send_sms(message_strings)
    end

    it "send_sms with member" do
      message_strings = ["1", "2", "3"]
      other_member = @r.pair.other_member(@m)

      args = {
        from:    @r.pair,
        to:      other_member,
        message: message_strings
      }

      allow(Sms).to receive(:create_and_send).with(any_args)
      expect(Sms).to receive(:create_and_send).with args

      @r.send_sms(message_strings, other_member)
    end

    it "send_reminder" do
      expect(Sms).to receive(:create_and_send)
      expect(@r.member).to receive(:increment_reminder_count!)
      @r.send_reminder
      expect(@r.status).to eq("sent")
    end

    it "send_doer_no_reply_messages" do
      expect(@r.member).to receive(:increment_doer_no_reply_count!)
      expect(@r).to receive(:send_sms)
      @r.send_doer_no_reply_messages
    end

    it "send_helper_no_reply_messages" do
      expect(@r.member).to receive(:increment_helper_no_reply_count!)
      expect(@r).to receive(:send_sms)
      @r.send_helper_no_reply_messages
    end

    it "send_both_no_reply_messages" do
      expect(@r.member).to receive(:increment_both_no_reply_count!)
      expect(@r).to receive(:send_sms)
      @r.send_both_no_reply_messages
    end

    it "pair_ids_for_no_reply_messages for one" do
      tnow = Time.now - (Reminder::NO_REPLY_MINUTES + 1).minute
      Reminder.where(pair_id: @pair_1.id).update_all(status: 1, last_reminder_time_utc: tnow)
      pair_ids = Reminder.pair_ids_for_no_reply_messages
      expect(pair_ids).to eq([@pair_1.id])
    end

    it "pair_ids_for_no_reply_messages for multiple" do
      tnow = Time.now - (Reminder::NO_REPLY_MINUTES + 1).minute
      Reminder.where(pair_id: @pair_ids).update_all(status: 1, last_reminder_time_utc: tnow)
      pair_ids = Reminder.pair_ids_for_no_reply_messages
      expect(pair_ids).to eq([@pair_1.id, @pair_2.id])
    end

    it "pair_ids_for_no_reply_messages for outside of time window" do
      tnow = Time.now - 21.minute
      Reminder.where(pair_id: @pair_ids).update_all(status: 1, last_reminder_time_utc: tnow)
      pair_ids = Reminder.pair_ids_for_no_reply_messages
      expect(pair_ids).to eq([])
    end

    it "pair_ids_for_no_reply_messages for inside window but unsent" do
      tnow = Time.now - (Reminder::NO_REPLY_MINUTES + 1).minute
      Reminder.where(pair_id: @pair_ids).update_all(status: 0, last_reminder_time_utc: tnow)
      pair_ids = Reminder.pair_ids_for_no_reply_messages
      expect(pair_ids).to eq([])
    end

    it "sent no reply messages when time was correct" do
      tnow = Time.now - (Reminder::NO_REPLY_MINUTES + 1).minute
      Reminder.where(pair_id: @pair_1.id).update_all(status: 1, last_reminder_time_utc: tnow)

      reminders = Reminder.where(pair_id: @pair_1.id)
      r1 = reminders[0]
      r2 = reminders[1]

      Reminder.send_no_reply_messages

      r1.reload
      r2.reload
      expect(r1.last_no_reply_sent_time_utc.to_i).to be_within(1).of(Time.now.utc.to_i)
      expect(r2.last_no_reply_sent_time_utc.to_i).to be_within(1).of(Time.now.utc.to_i)
    end


    it "sent one way no reply when one member rescheduled" do

      tnow = Time.now - (Reminder::NO_REPLY_MINUTES + 1).minute
      Reminder.update_all(status: 1, last_reminder_time_utc: tnow)
      @m.reminders.update_all(last_reminder_time_utc: Time.now - 2.hour)

      unsent_count_1 = Reminder.unsent.count
      sent_count_1   = Reminder.sent.count

      Reminder.send_no_reply_messages

      @r  = Reminder.find @r.id
      @r2 = Reminder.find @r2.id
      @r3 = Reminder.find @r3.id
      @r4 = Reminder.find @r4.id

      expect(@r2.last_no_reply_sent_time_utc.to_i).to be_within(1).of(Time.now.utc.to_i)
      expect(@r4.last_no_reply_sent_time_utc.to_i).to be_within(1).of(Time.now.utc.to_i)
      expect(@r.last_no_reply_sent_time_utc).to be_nil
      expect(@r3.last_no_reply_sent_time_utc).to be_nil
    end

    # TODO: DRY with above
    it "sent one way no reply when one member checked in" do

      tnow = Time.now - (Reminder::NO_REPLY_MINUTES + 1).minute
      Reminder.update_all(status: 1, last_reminder_time_utc: tnow)
      @m.checkins.update_all(done_at: Time.now - 2.hour)

      unsent_count_1 = Reminder.unsent.count
      sent_count_1   = Reminder.sent.count

      Reminder.send_no_reply_messages

      @r  = Reminder.find @r.id
      @r2 = Reminder.find @r2.id
      @r3 = Reminder.find @r3.id
      @r4 = Reminder.find @r4.id

      expect(@r2.last_no_reply_sent_time_utc.to_i).to be_within(1).of(Time.now.utc.to_i)
      expect(@r4.last_no_reply_sent_time_utc.to_i).to be_within(1).of(Time.now.utc.to_i)
      expect(@r.last_no_reply_sent_time_utc).to be_nil
      expect(@r3.last_no_reply_sent_time_utc).to be_nil
    end


    it "didn't send no reply messages when time is before no reply minutes" do
      tnow = Time.now - (Reminder::NO_REPLY_MINUTES - 1).minute
      Reminder.where(pair_id: @pair_1.id).update_all(status: 1, last_reminder_time_utc: tnow)

      reminders = Reminder.where(pair_id: @pair_1.id)
      r1 = reminders[0]
      r2 = reminders[1]

      Reminder.send_no_reply_messages

      r1.reload
      r2.reload
      expect(r1.last_no_reply_sent_time_utc).to be_nil
      expect(r2.last_no_reply_sent_time_utc).to be_nil
    end


  end
end
