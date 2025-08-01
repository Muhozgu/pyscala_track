defmodule Username do
  def sanitize(username) do
    username
    |> Enum.filter(&valid_char?/1)  # Filter out invalid characters
    |> List.to_string()             # Convert charlist to string
    |> substitute_german_chars()    # Substitute German characters with Latin equivalents
    |> String.replace(~r/[^a-z_]/, "")  # Remove anything that's not a lowercase letter, special German letters or underscore
    |> String.to_charlist()         # Convert back to charlist
  end

  # Check if the character is a valid Unicode character (you can add more checks here if necessary)
  defp valid_char?(char) do
    char in 97..122 or  # Lowercase letters a-z
    char == 223 or     # ß
    char in [228, 246, 252] or # ä, ö, ü
    char == 95          # Underscore (_)
  end

  # Substitute German characters with their Latin equivalents
  defp substitute_german_chars(username) do
    username
    |> String.replace("ä", "ae")  # Replace ä with ae
    |> String.replace("ö", "oe")  # Replace ö with oe
    |> String.replace("ü", "ue")  # Replace ü with ue
    |> String.replace("ß", "ss")  # Replace ß with ss
  end
end