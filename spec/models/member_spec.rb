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

    it "includes users in_group" do
      g  = FactoryGirl.create(:group)
      m1 = FactoryGirl.create(:member)
      m2 = FactoryGirl.create(:member)
      m3 = FactoryGirl.create(:member)
      g.add_member m2
      g.add_member m3
      expect(Member.in_group(g.id).pluck(:id)).to match_array([m2.id, m3.id])
    end

    it "set timezone from group" do
      g  = FactoryGirl.create(:group)
      m1 = FactoryGirl.create(:member)

      m1.time_zone = nil
      m1.save

      expect(m1.time_zone).not_to eq(g.time_zone)
      m1.update_time_zone_from_group g
      expect(m1.time_zone).to eq(g.time_zone)
    end
  end

  describe "pairs" do
    before :each do
      @m = FactoryGirl.create(:member)
      @pair_1 = FactoryGirl.create(:pair, member_1: @m)
      @pair_2 = FactoryGirl.create(:pair, member_2: @m)
      @inactive_pair = FactoryGirl.create(:pair, member_2: @m, active: false)
      @pair_ids = @m.pairs.pluck(:id).sort
    end

    it "created pairs correctly" do
      expect(@pair_ids).to match_array([@pair_1.id, @pair_2.id, @inactive_pair.id])
    end


    it "can_message? other member" do

      # Can message members you are in a pair with
      expect(@m.can_message?(@pair_1.member_2)).to eq(true)
      expect(@m.can_message?(@pair_2.member_1)).to eq(true)

      # can't message self
      expect(@m.can_message?(@pair_1.member_1)).to eq(false)

      # Can't message when in an inactive pair
      expect(@m.can_message?(@inactive_pair.member_2)).to eq(false)

    end

    it "in_pair_with? other member" do

      expect(@m.in_pair_with?(@pair_1.member_2)).to eq(true)
      expect(@m.in_pair_with?(@pair_2.member_1)).to eq(true)

      # Not in pair with self
      expect(@m.in_pair_with?(@pair_1.member_1)).to eq(false)

      # Doesn't count inactive pairs
      expect(@m.in_pair_with?(@inactive_pair.member_2)).to eq(false)

    end

    it "destroyed pairs correctly" do
      @m.destroy
      expect(Pair.with_member_id(@m.id).count).to eq(0)
    end

    it "set_defaults before validation on create" do
      @m = FactoryGirl.build(:member)
      @m.should_receive(:set_defaults)
      @m.valid?
    end

  end

end
