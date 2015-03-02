require "spec_helper"

describe Pair do
  it { should belong_to :group }
  it { should belong_to(:member_1).class_name("Member") }
  it { should belong_to(:member_2).class_name("Member") }
  it { should respond_to(:activity) }

  describe "instantiation" do
    let(:pair) { FactoryGirl.build(:pair) }
    subject { pair }
    it { should respond_to(:group) }
    it { should respond_to(:member_1) }
    it { should respond_to(:member_2) }
    it { should be_valid }
    it { should respond_to(:activity) }

    it "should set a default activity" do
      p = FactoryGirl.create(:pair, activity: nil)
      expect(p.activity).to eq(p.group.activity)
    end
  end
end
