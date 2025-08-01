def square(number):
    if 0 < number <= 64:
        return 2 ** (number - 1)
    else:
        raise ValueError("square must be between 1 and 64")


def total():
    array = []
    for n in range(1, 65):
        array.append(2 ** (n - 1))
    return sum(array)