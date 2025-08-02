def is_pangram(sentence):
    sentence = sentence.lower()
    alphabet = set('abcdefghijklmnopqrstuvwxyz')
    return alphabet <= set(sentence)

