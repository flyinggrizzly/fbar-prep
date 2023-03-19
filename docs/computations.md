# Computations

Supported computations are:

- `add`
- `coerce_number` TODO
- `concat` TODO
- `prefix` TODO
- `subtract` TODO
- `multiply`
- `first_not_null`
- `prefix`

## Add

`add` accepts an array of operands, which can be any of:

- a [special value](./special_values.md)
- a CSV header corresponding to a value in the row
- a computation, which case the value used will be that returned by the computation

All operands are coerced into being numbers with `Float(value)`, which means anything that isn't a clean conversion will
explode.

## Multiply

`multiply` accepts an array of operands, which can be any of:

- a [special value](./special_values.md)
- a CSV header corresponding to a value in the row
- a computation, which case the value used will be that returned by the computation

All operands are coerced into being numbers with `Float(value)`, which means anything that isn't a clean conversion will
explode.


## First not null

`first_not_null` accepts an array of operands, which can be any of:

- a [special value](./special_values.md)
- a CSV header corresponding to a value in the row
- a computation, which case the value used will be that returned by the computation

No coercion is performed on the operands before evaluation, since all it cares about is nullness.

`first_not_null` will also silently rescue errors raised by any computation operands, and coerce these fails to `nil`.

If after all values have been checked, no values are left, it will raise a `NoPossibleValuesError`. For this reason it
is useful to provide it a safe fallback as the last operand/parameter:

```yaml
amount:
  compute:
    first_not_null:
      - In
      - compute:
          multiply:
            - Out
            - $CONSTANTS.MINUS_ONE
      - $CONSTANTS.ZERO
```

## Prefix

`prefix` accepts two parameters: a **value to be prefixed**, and a **prefix string**.

The value to be prefixed can be computed or composed ('as usual') from

- a [special value](./special_values.md)
- a CSV header corresponding to a value in the row
- a computation, which case the value used will be that returned by the computation

and the prefix string must be a string literal--no transformation or computation is performed.

For example:

```yaml```
compute:
  prefix:
    - Detail
    - detail=
```

results in `"detail=Whatever the CSV had in the 'Detail' column"`

## Concat

`concat` accepts an array of operands, the first of which should be a hash to provide a delimiter string (optional,
default of " | "), and the rest of which can be any of:

- a [special value](./special_values.md)
- a CSV header corresponding to a value in the row
- a computation, which case the value used will be that returned by the computation

It will concatenate all of them into a single string, separated by the delimiter:

```yaml
compute:
  concat:
    - delimiter: "; "
    - compute:
        prefix:
          - Detail
          - detail=
    - compute:
        prefix:
          - Payer Name
          - payer=
    - compute:
        prefix:
          - Emojis and \#tags
          - dear_god_why_does_my_bank_support_emojis=
```

will result in `"detail=Detail col from CSV; payer=Payer from CSV; dear_god_why_does_my_bank_support_emojis=:smiley_face: #killing_it"`
