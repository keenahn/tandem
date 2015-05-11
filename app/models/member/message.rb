module Member::Message

  extend ActiveSupport::Concern
  attr_reader :member

  def initialize member
    @member = member
  end

end
