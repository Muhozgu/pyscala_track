def translate(text):
    vowels = ['a', 'e', 'i', 'o', 'u']
    result = []

    for word in text.split():
        w = word.lower()

        # Rule 1: Starts with vowel or "xr"/"yt"
        if w[0] in vowels or w.startswith("xr") or w.startswith("yt"):
            result.append(w + "ay")
            continue

        # Rule 3: Consonant(s) followed by "qu"
        if "qu" in w:
            qu_index = w.find("qu")
            if qu_index != -1 and all(c not in vowels for c in w[:qu_index]):
                result.append(w[qu_index + 2:] + w[:qu_index + 2] + "ay")
                continue

        # Rule 4: Consonant(s) followed by "y"
        for i in range(1, len(w)):
            if w[i] == 'y' and all(c not in vowels for c in w[:i]):
                result.append(w[i:] + w[:i] + "ay")
                break
        else:
            # Rule 2: Word starts with consonant(s)
            for i in range(len(w)):
                if w[i] in vowels:
                    result.append(w[i:] + w[:i] + "ay")
                    break
            else:
                # fallback: no vowels (like "hmm")
                result.append(w + "ay")

    return " ".join(result)

