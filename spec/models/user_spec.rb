require "spec_helper"

describe User do
  it { should have_many(:groups) }
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe "instantiation" do
    let(:user) { FactoryGirl.build(:user) }
    subject { user }
    it { should respond_to(:email) }
    it { should respond_to(:password) }
    it { should be_valid }
    it { should respond_to(:time_zone) }
    it "should set a default time zone" do
      u = FactoryGirl.create(:user, time_zone: nil)
      expect(u.time_zone).to eq(User::DEFAULT_TIMEZONE)
    end
  end
end
