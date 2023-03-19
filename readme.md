# fbar-prep

A CLI tool to calculate values required to report in an FBAR for the IRS.

## The problem

The IRS requires that US persons report the balance of all foreign financial accounts on the day that the combined total
value is the highest in a given tax year. This is a giant pain in the ass, especially when you've got a ton of accounts.

## How this solves it

This tool accepts a pile of CSVs for accounts, mappings files to tell it how to convert the CSV rows into its internal
`Statement::Transaction` model, and then does the work for you.

It then iterates over every day in the year, asks each `Account` record for its balance on that day (by one of two
stratgies--the end-of-day balance, or the highest balance on the day), and identifies the day with the total highest
balance. If an account has no transactions on a given date, the `RunningBalance` calculator scans back to the last
most-recent date and uses its last balance.

It then produces a CSV that includes:

- the FBAR threshold for the year ($10k, but you should include config data for currencies that match your local
  currency)
- the date of the highest combined value
- the value on that date for each account

## Limitations

- currently assumes a single currency (default config data is for GBP in `data/facta.yml`)
- it's unclear if EOD or Max is the appropriate strategy for reporting in the FBAR

### EOD vs. Max

I think technically MAX would be the correct approach, but this could open up situations where you might reprot a max
balance of n * AMOUNT, if you happened to transfer AMOUNT between multiple accounts on the same day. This is an edge
case, but be aware that running with MAX is the right start, but the EOD strategy can be a good sanity check.


## Usage

### Setup

Install the tool with `bundle install`. Depends on Ruby 3.1+

### Data prep

1. in the `data/` directory, for every bank/provider with which you have an account create a directory, and then...
2. for each account at that provider, create a sub-directory named for a memorable handle (e.g. "barclays-daily-1234")
3. place any CSV files for the account in that folder. You don't need to limit these to a specific year, the tool will
   only produce a report for the year you request in the CLI (tl;dr date filtering happens at runtime)
4. in either the bank/provider folder, or in the specific account folders if necessary, create a `mappings.yml` or
   `mappings.json` file to tell the tool how to convert from your CSV format into its own `Statement::Transaction`
    - the tool will first look for account specific mappings before provider-level, so if some exports are funny you can
      keep them separate. Alternatively if a bank's export format changes you can just create a new folder for it to
      avoid pita mappings accounting for multiple formats
5. Create an `accounts.yml` file in the `data/` root and add each account to it. Check the format in
   `data/accounts.demo.yml` for reference
6. Create `data/fatca.yml`, and add key-value pairs where the key is the year, and the value is the FBAR threshold for
   that year based on the published IRS exchange rate (e.g. GBP for 2020 would be `2020: 7790`).

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
│   │   └── mappings.yml
│   └── mappings.yml
└── nationwide-bs
    ├── mappings.yml
    └── nationwide-shared-bills-1234
        └── export-03-apr-2011.csv
```

In this structure, the statements for the accounts `barclays-daily-1234` and `barclays-savings-5678` will both use the
same `barclays/mappings.yml` because they don't have local ones in the account-specific directories, but the account
data in `legacy-csv-format-barclays-daily-1234` will prefer the local `barclays/legacy-csv-format-barclays-daily-1234/mappings.yml`.

#### Mappings files

The required fields for `Statement::Transaction` objects are

- `date` - `Date`
- `balance` - `Float` or `nil`
- `in` - `Float` or `nil`
- `out` - `Float` or `nil`
- `details` - `String` or `nil`
- `type` - `String` or `nil`

In addition, a `csv_filename_strptime_date_format` value is required, in order to identify the statement date. See [the
Ruby docs on `Date.strftime`](https://ruby-doc.org/stdlib-2.4.1/libdoc/date/rdoc/Date.html#method-i-strftime) for
formatting. **Be careful with this**, since banks are inconsistent with whether this is the date of generation (e.g. the
end of the month being represented), or the date of access (the time the statement was downloaded). As a rule, this is
there as a convenience and the row dates are far more important.

Assuming a CSV with headers `Date`, `Balance`, `Money In`, `Money Out`, `Transaction Information`, `Type`, a minimal YAML
mapping would look like this:

```yaml
mappings:
  date: Date
  balance: Balance
  in: Money In
  out: Money Out
  details: Transaction Information
  type: Type
csv_filename_strptime_date_format: export-%d-%b-%Y.csv
```

However, more complex mappings may be required and are possible.

Given a CSV that has the headers `TxnDate`, `Amount`, `TxnType`, `Notes`, and `Emoji and #tags` (yes I stg I have this), we have no
native field to supply the `balance` and `in` and `out` values to our `Transaction` object. Additionally, for some wild
reason the bank formats dates like `YYYY..MM..DD`, and so a transformation is required.

A more complex mapping that computes a balance from the previous transaction and the current amount is possible:

```yaml
mappings:
  date:
    field: TxnDate
    format: %Y..%d..%m
  in:
    compute:
      if:
        positive: Amount
        then: Amount
        else: null
  out:
    compute:
      if:
        negative: Amount
        then: Amount
        else: null
  balance:
    compute:
      add:
        - $TRANSACTIONS.PREVIOUS_BALANCE
        - Amount
  details:
    compute:
      concat:
        - Notes
        - Emoji and \#tags
  type: TxnType
```

### Running the tool

To generate a CSV report, once the tool is installed and data and mappings are prepped, run

`bundle exec rake generate_csv YEARS=2020,2021,2022 [STRATEGY={both|max|eod}]]`

It will generate a CSV for each year provided, using the strategy requested (default is to generate CSVs with data for
both `eod` and `max` strategies).
