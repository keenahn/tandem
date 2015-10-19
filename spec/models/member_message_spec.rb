require "spec_helper"

describe Member::Message do
  # it { should respond_to(:member) }

  describe "test1" do
    it "members" do
      m1 = FactoryGirl.create(:member)
      m2 = FactoryGirl.create(:member)
      m3 = FactoryGirl.create(:member)

      m2.seen_first_helper_reschedule  = true
      m2.seen_first_helper_yes         = true
      m2.seen_first_reminder           = true
      m2.seen_first_other_reminder     = true
      m2.seen_first_doer_no_reply      = true
      m2.seen_first_helper_no_reply    = true
      m2.seen_first_both_no_reply      = true
      m2.save

      m3.seen_second_helper_reschedule = true
      m3.seen_second_helper_yes        = true
      m3.seen_second_reminder          = true
      m3.seen_second_other_reminder    = true
      m3.seen_second_doer_no_reply     = true
      m3.seen_second_helper_no_reply   = true
      m3.seen_second_both_no_reply     = true
      m3.save

      Rails.logger.info m2
      Rails.logger.info m3

      mm1 = Member::Message.new(m1)
      mm2 = Member::Message.new(m2)
      mm3 = Member::Message.new(m3)

      Member::Message::SEEN_FNS.each{ |x, y|
        t1 = mm1.current_template_name x
        t2 = mm2.current_template_name x
        t3 = mm3.current_template_name x

        expect(t1).to eq("#{x}_#{Member::Message::FIRST_TIME}")
        expect(t2).to eq("#{x}_#{Member::Message::SECOND_TIME}")
        expect(t3).to eq("#{x}_#{Member::Message::POST_SECOND_TIME}")
      }
    end
  end


end
