module Concerns
  module ActiveInactiveMixin
    extend ActiveSupport::Concern

    included do
      scope :active,   ->{ where(active: true)  }
      scope :inactive, ->{ where(active: false) }

      validates :active, inclusion: [true, false]

    end

    # Instance methods

    # TODO: unit tests
    def activate
      self.active = true
    end

    # TODO: unit tests
    def deactivate
      self.active = false
    end

    # TODO: unit tests
    def activate!
      activate
      save
    end

    # TODO: unit tests
    def deactivate!
      deactivate
      save
    end

    # TODO: unit tests
    def active?
      active ? true : false
    end

  end
end
