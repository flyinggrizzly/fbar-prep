# Special Values

Special values are something like global constants that can be referred to in mappings.

At time of writing, there are two (with some special cases for one):

- `$TRANSACTIONS.PREVIOUS_BALANCE`
- `$CONSTANTS.NUMBER[n]`
- `$CONSTANTS.NULL`

## `$TRANSACTIONS.PREVIOUS_BALANCE`

This instructs the mapper to look up the balance as of the last transaction. This is useful if your CSV doesn't include
balances in each row and they must be calculated.

If no previous balance is available, 0.00 is returned.

## `$CONSTANTS.NUMBER[n]`

Most users will be using the shorthands for -1, 0, and 1:

- `$CONSTANTS.MINUS_ONE`
- `$CONSTANTS.ZERO`
- `$CONSTANTS.ONE`

but any numeric value *n* is possible using the `$CONSTANTS.NUMBER[n]` form, e.g.:

- `$CONSTANTS.NUMBER[3.14159] => 3.14159`
- `$CONSTANTS.NUMBER[-123] => -123.00`

Floats are always returned.

The requirement for the Number constant exists because the mapping shorthand of `in: In` is more useful most of the
time. Therefore special formatting is required to indicate an actual value to be used, instead of a CSV header/key.

## `$CONSTANTS.NULL`

Evaluates to `nil`.
