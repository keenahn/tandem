require "spec_helper"

describe Group do
  it { should belong_to(:owner).class_name("User").touch(true) }
  it { should have_many(:members).through(:group_memberships).dependent(:destroy) }
  it { should have_many(:group_memberships).dependent(:destroy) }
  it { should have_many(:pairs).dependent(:destroy) }
  it { should respond_to(:time_zone) }
  it { should respond_to(:activity) }

  it "should set a default time zone" do
    g = FactoryGirl.create(:group, time_zone: nil)
    expect(g.time_zone).to eq(g.owner.time_zone)
  end

  it "should set a default activity" do
    g = FactoryGirl.create(:group, activity: nil)
    expect(g.activity).to eq(Tandem::Activity::DEFAULT_ACTIVITY)
  end

  it ".to_s" do
    g = FactoryGirl.build(:group)
    expect(g.to_s).to eq(g.name)
  end

  it "add_member" do
    g = FactoryGirl.create(:group)
    m1 = FactoryGirl.create(:member)
    m2 = FactoryGirl.create(:member)
    m3 = FactoryGirl.create(:member)
    g.add_member m1
    g.add_member m3
    expect(g.members.pluck(:id)).to match_array([m1.id, m3.id])
  end


end
