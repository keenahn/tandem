require 'spec_helper'

describe Member do
  it { should have_and_belong_to_many :groups }
  it { should have_and_belong_to_many :pairs }

  it '.to_s' do
    m = Member.new(name: Faker::Name.name)
    expect(m.name).to eq(m.name)
  end
end
