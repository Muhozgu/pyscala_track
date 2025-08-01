defmodule HighSchoolSweetheart do
  def first_letter(name) do
    name
    |> String.trim()
    |> String.first()
  end

  def initial(name) do
    name
    |> first_letter()
    |> String.upcase()
    |> Kernel.<>(".")
  end

  def initials(full_name) do
    [first, last | _] = String.split(full_name)
    "#{initial(first)} #{initial(last)}"
  end

  def pair(full_name1, full_name2) do
    names = "#{initials(full_name1)}  +  #{initials(full_name2)}"
    message = "|  #{names}  |"
    border = "❤" <> String.duplicate("-", String.length(message) - 2) <> "❤"

    # Ensure a newline is added at the end of the output
    Enum.join([border, message, border], "\n") <> "\n"
  end
end



