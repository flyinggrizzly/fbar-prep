require 'yaml'

require './lib/data'
require './lib/csv_map'

module FBARPrep
  class CSVMap
    module Factory
      extend self

      def build(account)
        provider = account.provider
        handle = account.handle

        filetypes = [
          'mapping.json',
          'mapping.yml',
          'mapping.yaml'
        ]

        account_level_mappings = Data.children(provider, handle, filetypes:)

        raise "too many mappings for account #{handle}" unless account_level_mappings.size < 2

        return CSVMap.new(YAML.load_file(account_level_mappings.first)) if account_level_mappings.size == 1

        provider_level_mappings = Data.children(provider, filetypes:)

        raise "too many mappings for provider #{provider}" if provider_level_mappings.size > 1

        return CSVMap.new(YAML.load_file(provider_level_mappings.first)) if provider_level_mappings.size == 1

        raise "need a mapping for provider #{provider} or account #{handle}"
      end
    end
  end
end
