"""Functions to help Azara and Rui locate pirate treasure."""

# https://exercism.org/tracks/python/exercises/tisbury-treasure-hunt
def get_coordinate(treasure):
    return treasure[1]

def convert_coordinate(coordinate):
  distributed = tuple(coordinate)
  return distributed


def compare_records(azara_record, rui_record):
  rui_record_1 = rui_record[1]
  rui_record_full = rui_record_1[0] + rui_record_1[1]
  rui_record_full = str(rui_record_full)
  return rui_record_full == azara_record[1]


def create_record(azara_record, rui_record):
  if compare_records(azara_record, rui_record):
    combined = azara_record + rui_record
    return combined
  else:
    return "not a match"


def clean_up(combined_record_group):
    report_lines = []
    for record in combined_record_group:
        cleaned_record = (record[0], record[2], record[3], record[4])
        report_lines.append(str(cleaned_record))
    
    return "\n".join(report_lines) + "\n"