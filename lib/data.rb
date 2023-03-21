require 'date'
require 'yaml'

module FBARPrep
  module Data
    extend self

    def children(*path_elements, filetypes: 'csv')
      accepted_filetypes = Array(filetypes || 'csv')

      Dir.children(File.join(data_dir, *path_elements))
        .filter {|name| name.end_with?(*accepted_filetypes)}
        .map {|name| File.join(data_dir, *path_elements, name)}
    end

    def fatca_thresholds
      YAML.load_file(File.join(data_dir, 'fatca.yml')).fetch('fatca_thresholds')
    end

    def irs_exchange_rate_for(currency, year)
      YAML.load_file(File.join(data_dir, 'fatca.yml')).fetch('irs_published_exchange_rates').fetch(currency).fetch(year)
    end

    def account_records
      records = account_data.fetch('accounts')
        .reject {|a| a['pending']}
        .map do |yaml_record|
          AccountRecord.new(
            handle: yaml_record.fetch('handle'),
            type: yaml_record.fetch('type'),
            provider: yaml_record.fetch('provider'),
            number: yaml_record.fetch('number', nil),
            sort_code: yaml_record.fetch('sort', nil),
            opening_date: yaml_record.fetch('opening_date'),
            closing_date: yaml_record.fetch('closing_date', nil),
            joint: yaml_record.fetch('joint', false),
            virtual: yaml_record.fetch('virtual', false)
          )
        end

      raise "duplicated handle" unless records.map(&:handle).uniq.size == records.size

      records
    end

    def account_records_for_provider(provider_handle)
      account_records.filter {|ar| ar.provider == provider_handle}
    end

    def provider_records
      records = account_data.fetch('providers')
        .reject {|p| p['pending']}
        .map {|yaml| ProviderRecord.new(
          handle: yaml.fetch('handle'),
          name: yaml.fetch('name'),
          address: yaml.fetch('address')
        )}

      raise "duplicated handle" unless records.map(&:handle).uniq.size == records.size

      records
    end

    def provider_record_for_handle(provider_handle)
      provider_records.detect {|pr| pr.handle == provider_handle}
    end

    AccountRecord = Struct.new(
      :handle,
      :type,
      :provider,
      :currency,
      :number,
      :sort_code,
      :opening_date,
      :closing_date,
      :joint,
      :virtual,
      keyword_init: true
    ) do
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

    def account_data
      YAML.load_file(File.join(data_dir, account_data_filename), permitted_classes: [Date])
    end

    def data_dir
      File.expand_path('./data')
    end

    # Useful hook for substituting in test data
    def account_data_filename
      'accounts.yml'
    end
  end
end
