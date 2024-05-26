require './lib/data'

module FBARPrep
  module Data
    class AccountRecord
      module IrsStatus
        extend(self)

        class UsPerson
          class << self
            def identifiers
              ['citizen', 'resident']
            end
          end
        end
        US_PERSON = UsPerson.new

        class NonResidentAlien
          class << self
            def identifiers
              ['non-resident alien', 'non resident alien', 'non_resident_alien', nil]
            end
          end
        end
        NON_RESIDENT_ALIEN = NonResidentAlien.new

        def from(string)
          if UsPerson.identifiers.include?(string)
            US_PERSON
          elsif NonResidentAlien.identifiers.include?(string)
            NON_RESIDENT_ALIEN
          else
            raise "unknown IRS status #{string}"
          end
        end
      end

      JointHolder = Struct.new(
        :name,
        :us_tax_status,
        keyword_init: true
      ) do
        def summary(with_us_tax_status: true)
          return name unless with_us_tax_status

          "#{name} (#{us_tax_status})"
        end
      end

      def initialize(
        handle:,
        type:,
        provider:,
        currency:,
        number:,
        sort_code:,
        policy_number:,
        opening_date:,
        closing_date:,
        joint:,
        virtual:,
        joint_holders:
      )
        @handle = handle
        @type = type
        @provider = provider
        @currency = currency
        @number = number
        @sort_code = sort_code
        @policy_number = policy_number
        @opening_date = opening_date
        @closing_date = closing_date
        @joint = joint
        @virtual = virtual
        @joint_holders = joint_holders
      end

      attr_reader :handle, :type, :provider, :currency, :number, :sort_code, :policy_number, :opening_date,
        :closing_date, :joint, :virtual, :joint_holders

      def bank_account?
        ['current', 'savings'].include?(type)
      end

      def virtual?
        virtual == true
      end

      def provider_record
        @provider_record ||= Data.provider_record_for_handle(provider)
      end

      def full_provider_name
        provider_record.name
      end

      def address
        provider_record.address
      end
    end
  end
end
