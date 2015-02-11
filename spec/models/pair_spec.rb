require 'spec_helper'

describe Pair do
  it { should belong_to :group }
  it { should belong_to(:member_1).class_name("Member") }
  it { should belong_to(:member_2).class_name("Member") }
end
