def rebase(input_base, digits, output_base):
    # --- Validate bases ---
    if input_base < 2:
        raise ValueError("input base must be >= 2")
    if output_base < 2:
        raise ValueError("output base must be >= 2")

    # --- Validate digits ---
    if not digits:
        return [0]

    # Leading zeros are allowed but should not break anything.
    for d in digits:
        if d < 0 or d >= input_base:
            raise ValueError("all digits must satisfy 0 <= d < input base")

    # --- Convert input digits to integer value ---
    value = 0
    for d in digits:
        value = value * input_base + d

    # Special case: value = 0
    if value == 0:
        return [0]

    # --- Convert integer value to output-base digits ---
    result = []
    while value > 0:
        value, rem = divmod(value, output_base)
        result.append(rem)

    # Digits are built least-significant-first, so reverse:
    return result[::-1]

