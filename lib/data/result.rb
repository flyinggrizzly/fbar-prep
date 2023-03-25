module FBARPrep
  module Data
    class Result
      class << self
        def ok(value)
          new(true, value)
        end

        def error(value)
          new(false, value)
        end
      end

      def initialize(success, value)
        @success = success
        @value = value
      end

      attr_reader :success, :value

      def ok?
        @success
      end

      def error?
        !@success
      end

      def ok_value
        raise unless ok?

        value
      end

      def error_value
        raise unless error?

        value
      end
    end
  end
end
