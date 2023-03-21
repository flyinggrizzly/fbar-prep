require 'date'
require 'active_support/all'

require_relative './currency'
require_relative './account'
require_relative './check_sequentiality_of_statements'
require_relative './generate_fbar_report'
require_relative './fbar_tax_year'

module FBARPrep
  extend self

  def check_sequentiality_of_statements(account, clamp_from: Date.new(0000, 1, 1), clamp_to: Date.current.last_month)
    CheckSequentialityOfStatements.new(account, clamp_from:, clamp_to:).perform
  end

  def generate_report(year, account_or_accounts, strategy: :both)
    GenerateFBARReport.new(FBARTaxYear.for(year), Array(account_or_accounts), strategy:).perform
  end

  def account(handle)
    Account.for(handle)
  end

  def accounts
    Account.all
  end
end
