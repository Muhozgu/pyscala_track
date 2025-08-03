def is_valid(isbn):
    # Supprimer les tirets et espaces
    isbn = isbn.replace("-", "").replace(" ", "")
    
    # Vérification ISBN-10
    if len(isbn) == 10:
        total = 0
        for i in range(9):
            if not isbn[i].isdigit():
                return False
            total += int(isbn[i]) * (10 - i)
        # Dernier caractère : chiffre ou X (valant 10)
        if isbn[9] == "X":
            total += 10
        elif isbn[9].isdigit():
            total += int(isbn[9])
        else:
            return False
        return total % 11 == 0

    # Vérification ISBN-13
    elif len(isbn) == 13 and isbn.isdigit():
        total = 0
        for i in range(13):
            factor = 1 if i % 2 == 0 else 3
            total += int(isbn[i]) * factor
        return total % 10 == 0

    # Si ce n'est ni ISBN-10 ni ISBN-13
    return False



    