require 'spec_helper'

describe Group do
  it { should belong_to :user }
  it { should have_and_belong_to_many :members }
  it { should have_many :pairs }

  it '.to_s' do
    g = FactoryGirl.build(:group)
    expect(g.name).to eq(g.name)
  end

end
