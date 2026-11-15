def rows(letter):
    letter = letter.upper()
    n = ord(letter) - ord('A')
    lines = []
    
    # Generate the top half and bottom half of the diamond
    for i in range(2 * n + 1):
        curr_index = i if i <= n else 2 * n - i
        curr_letter = chr(ord('A') + curr_index)
        
        outer_spaces = ' ' * (n - curr_index)
        
        if curr_index == 0:
            line = outer_spaces + 'A' + outer_spaces
        else:
            inner_spaces = ' ' * (2 * curr_index - 1)
            line = outer_spaces + curr_letter + inner_spaces + curr_letter + outer_spaces
            
        lines.append(line)
        
    return lines