module Concerns
  module SmsableMixin
    extend ActiveSupport::Concern

    included do
      has_many :sent_sms, class: Sms, dependent: :destroy, as: :from
      has_many :received_sms, class: Sms, dependent: :destroy, as: :to
    end

    # Instance methods
    def can_message? x
      raise "this method should be overriden: #{self.class.name}.can_message?"
    end

  end
end
