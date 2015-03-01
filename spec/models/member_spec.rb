require "spec_helper"

describe Member do
  it { should have_many(:groups).through(:group_memberships) }
  it { should have_many(:group_memberships).dependent(:destroy) }
  it { should respond_to(:time_zone) }

  it ".to_s" do
    m = Member.new(name: Faker::Name.name)
    expect(m.name).to eq(m.name)
  end

  describe "groups" do
    it "should set a default time zone" do
      g = FactoryGirl.create(:group_with_members)
      m = g.members.first
      expect(m.time_zone).to eq(g.time_zone)
    end
  end

  describe "pairs" do
    before :each do
      @m = FactoryGirl.create(:member)
      @pair_1 = FactoryGirl.create(:pair, member_1: @m)
      @pair_2 = FactoryGirl.create(:pair, member_2: @m)
      @pair_ids = @m.pairs.pluck(:id).sort
    end

    it "created pairs correctly" do
      expect(@pair_ids).to match_array([@pair_1.id, @pair_2.id])
    end

    it "destroyed pairs correctly" do
      @m.destroy
      expect(Pair.with_member_id(@m.id).count).to eq(0)
    end
  end
end
