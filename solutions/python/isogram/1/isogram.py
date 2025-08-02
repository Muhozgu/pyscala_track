def is_isogram(string):
    string = string.lower()
    letters_seen = set()

    for char in string:
        if char.isalpha():  # only check letters
            if char in letters_seen:
                return False
            letters_seen.add(char)
    return True