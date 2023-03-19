# Mapping files

Mapping files should be written in JSON or YAML.

The required keys are:

- `csv_filename_strptime_date_format`
- `first_csv_row_is`
- `mappings`
  - `balance`
  - `date`
    - `field`
    - `format`

Additionally, `Transaction` objects will record the following optional `mappings` keys:

- `details`
- `type`
- `amount`

Mapping a value to these keys is as simple as providing the header of the CSV row to use for each one (`date` is kind of
a special case):

Given a CSV with headers `Balance`, `Amount`, and `Date`, the following mapping snippet would be sufficient:

```yaml
mappings:
  balance: Balance
  amount: Amount
  date: field: Date
    format: %Y-%m-%d
```

## Required entries

### `csv_filename_strptime_date_format`

This is a `strftime`/`strptime` formatting string passed to `Date.strptime(mapped_csv_field,
csv_filename_strptime_date_format)` to extract the date from the CSV filename.

These either represent the time the CSV was generated (e.g. first business day following the close of the
month/quarter), or the time the report was accessed (e.g. last Friday when you panicked about the IRS filing deadline).

As such, these aren't all that meaningful, but if you're doing more here than generating a CSV they can be useful to
determine which CSV file some data came from.

### `first_csv_row_is`

Some banks do ascending date order, others do descending, and I hope to god those are the only options.

`newest` indicates the CSV is in descending date order.

`oldest` indicates the CSV is in ascending date order.

### `mappings`

#### `balance`

The value of the account after the transaction represented by the row is complete.

#### `date`

The date of the transaction row.

This has two required subfields:

- `field`, indicating which column to read in the CSV
- `format`, again a `strptime` format to tell the tool how to parse the date

`format` is required because this tool is specifically intended for cross-border users, and guessing at dates is hard
enough as a human, and I don't trust computers any more than I do me (which is to say very very little).

## Optional entries

TODO

## Computing a mapping when it's not simple

[Docs on computations supported](./computations.md)

[Docs on special values](./special_values.md)

Sometimes, CSV exports are designed by weirdos and we have to do some legwork to make them useable. If you've got a
metric ton of files, it would be a pita (and error-prone) to manually transform them, so this tool provides some
relatively basic transformation and computation options:

- Special values, like `$TRANSACTIONS.PREVIOUS_BALANCE` or `$CONSTANTS.NUMBER[n]`
- Computations, like `add`, `first_not_null`, and `multiply`

These are composable, and should allow handling situations like these examples:

### Computing a missing balance

Some wack-ass exports (Monzo...) don't include running balances in the rows, so you gotta do some dumbass computer's job for it.

This mapping snippet would look at each row, and using the running balance from the prior rows (or 0 for the first row)
calculate a balance for the current row:

```yaml
mappings:
  balance:
    compute:
      add:
        - $TRANSACTIONS.PREVIOUS_BALANCE
        - Amount
```

### Computing a missing amount

Some banks include an `In` and `Out` column in their export instead of a single `Amount` column, and in some cases both
in and out are represented as positive Floats, with the debit being implicit.

This tool's `Transaction` object looks for a single `amount` value, that should be a signed float, and so it must be
recomputed in these cases.

This snippet will take the first non-nil value it finds in the array `[row['In'], (-1 * row['Out']), 0]` (it also handles bad
multiplication with the expectation that you provide a safe fallback like 0). It handles the positiveness of the `Out`
value with a nested computation to multiply the value by `-1`.

```yaml
mappings:
  amount:
    first_not_null:
      - In
      - compute:
          multiply:
            - Out
            - $CONSTANTS.MINUS_ONE
      - $CONSTANTS.ZERO
```

### Putting these together

You could of course have a complete nightmare where a bank had neither a balance, nor a single signed `Amount` column,
and have to do it all yourself:

```yaml
mappings:
  balance:
    compute:
      add:
        - $TRANSACTIONS.PREVIOUS_BALANCE
        - compute:
            first_not_null:
              - In
              - compute:
                  multiply:
                    - Out
                    - $CONSTANTS.NUMBER[-1]
              - $CONSTANTS.NUMBER[0]
  amount:
    compute:
      first_not_null:
        - In
        - compute:
            multiply:
              - Out
              - $CONSTANTS.NUMBER[-1]
        - $CONSTANTS.NUMBER[0]
```

Yes, the `first_not_null` computation is repeated twice, which is intentional since introducing self-referential
computations could create order-dependencies and infinite loops in the transaction construction.
