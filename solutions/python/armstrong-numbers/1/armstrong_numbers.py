def is_armstrong_number(number):
    # Convert the number to a string to get its digits
    digits = str(number)
    num_digits = len(digits)
    
    # Calculate the sum of each digit raised to the power of the number of digits
    total = sum(int(digit) ** num_digits for digit in digits)
    
    # Compare the sum with the original number
    return total == number
