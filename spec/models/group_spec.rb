require "spec_helper"

describe Group do
  it { should belong_to(:owner).class_name("User").touch(true) }
  it { should have_many(:members).through(:group_memberships).dependent(:destroy) }
  it { should have_many(:group_memberships).dependent(:destroy) }
  it { should have_many(:pairs).dependent(:destroy) }

  it '.to_s' do
    g = FactoryGirl.build(:group)
    expect(g.name).to eq(g.name)
  end

end
