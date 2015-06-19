require "spec_helper"

RSpec.describe Checkin, type: :model do

  it { should belong_to(:member) }
  it { should belong_to(:pair) }

  [:member, :pair, :local_date].each do |f|
    it { should validate_presence_of(f) }
  end

  it { should validate_uniqueness_of(:local_date).scoped_to([:member_id, :pair_id]) }

  it "should call set_defaults before validation on create" do
    @c = FactoryGirl.build(:checkin)
    @c.should_receive(:set_defaults)
    @c.valid?
  end











  # it "should set a default time zone" do
  #   g = FactoryGirl.create(:group, time_zone: nil)
  #   expect(g.time_zone).to eq(g.owner.time_zone)
  # end

  # it "should set a default activity" do
  #   g = FactoryGirl.create(:group, activity: nil)
  #   expect(g.activity).to eq(Tandem::Activity::DEFAULT_ACTIVITY)
  # end

  # it ".to_s" do
  #   g = FactoryGirl.build(:group)
  #   expect(g.to_s).to eq(g.name)
  # end

  # it "add_member" do
  #   g = FactoryGirl.create(:group)
  #   m1 = FactoryGirl.create(:member)
  #   m2 = FactoryGirl.create(:member)
  #   m3 = FactoryGirl.create(:member)
  #   g.add_member m1
  #   g.add_member m3
  #   expect(g.members.pluck(:id)).to match_array([m1.id, m3.id])
  # end




end
