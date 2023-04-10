require 'yaml'

require './lib/data'
require './lib/csv_map'

module FBARPrep
  class CSVMap
    module Factory
      extend self

      FILETYPES = [
        'mapping.json',
        'mapping.yml',
        'mapping.yaml'
      ].freeze

      def build(account)
        file = account_level_mapping_file(account) || provider_level_mapping_file(account)

        raise "need a mapping for provider #{provider} or account #{handle}" if file.nil?

        CSVMap.new(YAML.load_file(file))
      end

      def provider_level_mapping_file(account)
        provider = account.provider

        Data.children(provider, filetypes: FILETYPES).tap do |files|
          raise "too many mappings for provider #{provider}" if files.size > 1
        end
          .first
      end

      def account_level_mapping_file(account)
        provider = account.provider
        handle = account.handle

        Data.children(provider, handle, filetypes: FILETYPES).tap do |files|
          raise "too many mappings for account #{handle}" if files.size > 1
        end
          .first
      end
    end
  end
end
