def is_valid_triangle(sides):
    a, b, c = sorted(sides)
    return all(side > 0 for side in sides) and a + b >= c

def equilateral(sides):
    if not is_valid_triangle(sides):
        return False
    return sides[0] == sides[1] == sides[2]

def isosceles(sides):
    if not is_valid_triangle(sides):
        return False
    a, b, c = sides
    return a == b or b == c or a == c

def scalene(sides):
    if not is_valid_triangle(sides):
        return False
    a, b, c = sides
    return a != b and b != c and a != c
