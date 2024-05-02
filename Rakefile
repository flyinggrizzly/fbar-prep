require 'pry'
require 'date'

require './lib/fbar_prep'
require './lib/data'

task :validate do
  clamp_from_month = ENV.fetch('CLAMP_FROM', '2018-01')
  clamp_from = clamp_from_month + '-01'

  puts "===\n\n"

  accounts.each do |account|
    puts "validating #{account.handle...}\n"

    result = FBARPrep.check_sequentiality_of_statements(
      account,
      clamp_from: Date.parse(clamp_from)
    )

    if result.ok?
      puts "account #{account.handle} has OK data"
    else
      duped_dates = result.duplicates.map {|h| "#{h[:year]-h[:month]}"}.join(', ')
      puts "account #{account.handle} has duped CSVs for #{duped_dates}" unless result.duplicates.empty?

      tail_gapped_dates = result.beginning_or_end_of_year_gaps.map {|h| "#{h[:year]}-#{h[:month]}"}.join(', ')
      puts "account #{account.handle} has year beginning/end gaps in CSVs for #{tail_gapped_dates}" unless result.beginning_or_end_of_year_gaps.empty?
    end

    puts "\n===\n\n"
  end
end

desc <<~DESC
  Generates CSV(s) for available data.

  Parameters can be passed as env vars.

  Supported parameters:

    YEAR=YYYY, the year to generate a report for. Default is to generate a report for all years defined in `fatca.yml`.
DESC
task :generate_csv do
  strategy = ENV.fetch('STRATEGY', 'both').to_sym

  year = ENV['YEAR']&.to_i
  years = Array(year || FBARPrep::Data.years)

  years.each do |year|
    FBARPrep.generate_report(year, FBARPrep.accounts, strategy:)
  end
end

task :clean do
  puts `rm output/*`
end
