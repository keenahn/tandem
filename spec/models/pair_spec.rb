require "spec_helper"

describe Pair do
  it { should belong_to :group }
  it { should belong_to(:member_1).class_name("Member") }
  it { should belong_to(:member_2).class_name("Member") }

  describe "instantiation" do
    let(:pair) { FactoryGirl.build(:pair) }
    subject { pair }
    it { should respond_to(:group) }
    it { should respond_to(:member_1) }
    it { should respond_to(:member_2) }
    it { should be_valid }
  end
end
