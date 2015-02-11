require 'spec_helper'

describe Activity do
  Activity::STRING_FIELDS.each{|x|
    it { should validate_presence_of x}
    it { should validate_length_of(x).is_at_most(255) }
  }
end
