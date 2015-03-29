# Just some quick, useful functions for ActiveRecords
module Concerns
  module ActiveRecordExtensions
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods

      # Not the most efficient, but whatever
      def random
        order("RANDOM()").first
      end

      def last_created
        order("created_at DESC").first
      end

      def last_updated
        order("updated_at DESC").first
      end

    end

  end
end