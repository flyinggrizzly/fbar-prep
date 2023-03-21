# Account.yml files

The format for `accounts.yml` is as follows:

```yaml
providers:
  - handle: demo-bank 
    name: Demo Bank PLC
    address: 123 Bankers Row, London, EC22 1BB, UK
accounts:
  - handle: demo-bank-daily-1234
    provider: demo-bank # should match the provider.handle entry, links the two records
    type: current | savings | pension | investment
    opening_date: YYYY-MM-DD # used in some checks for whether the account might be missing data
    number: 12345678 # account number, used in generated reports, only for current or savings accounts
    sort: 223344 # sort code, used in generated reports, only for current or savings accounts
    policy_number: TK1234 # pension or investment account identifier, used in generated reports
    joint: true | false # whether the account is jointly held, optional
    virtual: true | false # whether the account is a virtual one like a Monzo pot, optional

```

## `providers`

You should add an entry for every account provider you have. They have 3 required fields:

- `handle`, a useful shorthand identifier, which must correspond to their folder name in `data/`
- `name`, the bank's formal legal name, required for the generated CSV reports
- `address`, the bank's head office address, required for the generated CSV reports

## `accounts`

Add an entry for every account you have. Accounts have 3 required fields, and a few optional fields:

- `handle`, required, a useful shorthand identifier which must correspond to the account's folder in
  `data/provider-handle/`
- `provider`, required, and must be one of the `handle`s for one of the providers defined in the YAML file
- `opening_date`, required, used for some checks whether the account might be missing some data
- `type`, required, if the type is of `current` or `savings` this triggers some bank-specific behavior

**Optional fields:**

- `number`, for current and savings accounts only
- `sort`, sort code, for current and savings accounts only
- `policy_number`, for pensions and investment accounts
- `joint`, boolean, whether the account is jointly held
- `virtual`, boolean, whether the account is a virtual account like a Monzo pot

## Other fields

If you add `pending: true` to either an account or a provider, it will be excluded from the report.
