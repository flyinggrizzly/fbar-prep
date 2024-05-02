# fbar-prep

A CLI tool to calculate values required to report in an FBAR for the IRS.

## DISCLAIMER

I am not a lawyer. I am not a qualified tax professional. This tool is provided as-is, bugs included, and is used at
your own risk.

Mistakes filing the FBAR can be $10k *per misfiled account*, so please use this tool responsibly, wisely, and
skeptically. It might be wrong. You should review, or have a tax professional review, the results of it and your FBAR
report before you submit them to the IRS.

I don't *think* there are bugs here, but [smarter people than me have fucked up
worse](https://www.wired.com/2010/11/1110mars-climate-observer-report/), so treat this tool with hostility.

## The problem

It's a pain in the butt to trawl through bank statements to find the highest balance during a given period. This tool
automates that, given some CSV data.

## How this solves it

This tool accepts a pile of CSVs for accounts, mappings files to tell it how to convert the CSV rows into its internal
`Statement::Transaction` model, and then does the work for you.

For each `Account`, it finds the highest balance and data, and adds it to a CSV. For quiet accounst that had no
transactions during the year, it will use the most recent balance available (e.g. last transaction was 2021-01-01, and
you're prepping an FBAR for 2023: it will give you the balance as of 2021-01-01). This assumes that you are not trying
to generate data for accounts that are closed, and that you have added all available data. Some providers will only give
you CSV data for time periods in which they had activity, so this will scan back to account for quiet months/years.

It then produces a CSV that includes:

- the FBAR threshold for the year ($10k, but you should include config data for currencies that match your local
  currency)
- for each account, an entry with the data and highest balance, as well as EOY balances, and the requisite reporting
  info like bank name, account identifiers, address, etc

## Usage

### Setup

Install the tool with `bundle install`. Depends on Ruby 3.1+

### Data prep

In the `data/` directory...

1. add a `fatca.yml` file, with a top-level key of of `irs_published_exchange_rates`, followed by blocks for any
   currencies you need (e.g. `gbp`, `eur`). Under these blocks add key-value pair entries for each year you need to
   report, with the IRS published exchange rate for that year as the value (this should be the Dollar -> Local exchange
   rate, with for GBP is usually < 1.0). You can find the rates, or instructions for finding other rates, on [the IRS
   site](https://www.irs.gov/individuals/international-taxpayers/yearly-average-currency-exchange-rates). You can also
   optionally add a `years` entry, with an array of years you want to generate reports for (if more than one supplied
   via CLI)
2. for each bank/pension provider you have data for, create a subdirectory with a simple name (e.g. "Barclays PLC" =>
   "barclays")
3. for each account with each provider, create a subdirectory for the account with a simple name (e.g.
   `data/barclays/barclays-daily-1234`). Repeat this for every account with every provider. Put your export CSV data
   for the account here. You don't need to limit these to a specific year, the tool will
   only produce a report for the year you request in the CLI (tl;dr date filtering happens at runtime)
4. in either the bank/provider folder, or in the specific account folders if necessary, create a `mapping.yml` or
   `mapping.json` file to tell the tool how to convert from your CSV format into its own `Statement::Transaction`. See
   [detailed documentation for format and complex mapping cases](./docs/mapping_files.md)
    - the tool will first look for account specific mappings before provider-level, so if some exports are funny you can
      keep them separate. Alternatively if a bank's export format changes you can just create a new folder for it to
      avoid pita mappings accounting for multiple formats
5. Create an `accounts.yml` file in the `data/` root and add each account to it. Check the format in
   `data/accounts.demo.yml` for reference. Note that the `handle` entry you need for each account should be the same as
   the account folder name (`barclays-daily-1234`) and the `provider` entry should match the provider folder
   (`barclays`). See [docs for more detailed info](./docs/account_yml_files.md)

Example filestructure:

```bash
% tree data
data
├── accounts.yml
├── fatca.yml
├── barclays
│   ├── barclays-daily-1234
│   │   ├── export-jun-30-2010.csv
│   │   └── export-may-31-2010.csv
│   ├── barclays-savings-5678
│   │   └── export-jun-30-2010.csv
│   ├── legacy-csv-format-barclays-daily-1234
│   │   ├── export-1999-12-01.csv
│   │   └── mapping.yml
│   └── mapping.yml
└── nationwide-bs
    ├── mapping.yml
    └── nationwide-shared-bills-1234
        └── export-03-apr-2011.csv
```

In this structure, the statements for the accounts `barclays-daily-1234` and `barclays-savings-5678` will both use the
same `barclays/mappings.yml` because they don't have local ones in the account-specific directories, but the account
data in `legacy-csv-format-barclays-daily-1234` will prefer the local `barclays/legacy-csv-format-barclays-daily-1234/mappings.yml`.

#### Mappings files

This section covers basic simple mapping cases, [see the docs for more difficult mappings require calculation or
transformation](./docs/mapping_files.md)

The required fields for `Statement::Transaction` objects are

- `date` - `Date`
- `balance` - `Float` or `nil`

You can optionally include as well:

- `amount` = `Float` or `nil`
- `details` - `String` or `nil`
- `type` - `String` or `nil`

Date mappings require both a `field` and a `format` entry, where the format [is one supported by
`Date#strftime`](https://ruby-doc.org/stdlib-2.4.1/libdoc/date/rdoc/Date.html#method-i-strftime).

Assuming a CSV with headers `Date`, `Balance`, `Amount`, `Transaction Information`, `Type`, a minimal YAML
mapping would look like this:

```yaml
mappings:
  date:
    field: Date
    format: '%Y-%m-%d'
  balance: Balance
  amount: Amount
  details: Transaction Information
  type: Type
```

### Running the tool

To generate a CSV report, once the tool is installed and data and mappings are prepped, run

`bundle exec rake generate_csv [YEARS=2020,2021,2022]`

