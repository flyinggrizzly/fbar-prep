require './lib/data'

module FBARPrep
  module Data
    ProviderRecord = Struct.new(
      :handle,
      :name,
      :address,
      keyword_init: true
    ) do
      def account_records
        @account_records ||= Data.account_records_for_provider(handle)
      end
    end
  end
end
