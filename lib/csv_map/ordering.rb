module FBARPrep
  class CSVMap
    module Ordering
      extend self

      NEW = [
        'new',
        'newest'
      ].freeze

      OLD = [
        'old',
        'oldest'
      ].freeze

      def reverse?(value)
        NEW.include?(value)
      end

      def static?(value)
        OLD.include?(value)
      end

      def valid?(value)
        reverse?(value) || static?(value)
      end
    end
  end
end

