def to_rna(dna_strand):
  arr = []
  for seq in dna_strand:
    if seq == 'G':
      arr.append('C')
    elif seq == 'C':
      arr.append('G')
    elif seq == 'T':
      arr.append('A')
    elif seq == 'A':
      arr.append('U')
  return ''.join(arr)
