require 'date'

require './lib/fbar_prep'

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

task :generate_csv do
  strategy = ENV.fetch('STRATEGY', 'both').to_sym

  years = FBARPrep::Data.fatca_thresholds.keys

  years.each do |year|
    FBARPrep.generate_report(year, FBARPrep.accounts, strategy:)
  end
end

task :clean do
  puts `rm output/*`
end
