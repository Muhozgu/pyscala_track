def is_paired(input_string):
    stack = []
    pairs = {
        ")": "(",
        "]": "[",
        "}": "{"
    }

    for char in input_string:
        if char in "([{":
            stack.append(char)

        elif char in ")]}":
            if not stack or stack[-1] != pairs[char]:
                return False

            stack.pop()

    return len(stack) == 0