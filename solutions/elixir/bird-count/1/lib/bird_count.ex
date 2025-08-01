defmodule BirdCount do
  # Returns the number of birds counted today (head of the list)
  def today([head | _tail]), do: head
  def today([]), do: nil

  # Increments the count for today (head of the list)
  def increment_day_count([head | tail]), do: [head + 1 | tail]
  def increment_day_count([]), do: [1]

  # Checks if any day had 0 birds
  def has_day_without_birds?(list), do: Enum.any?(list, fn count -> count == 0 end)

  # Sums the total number of birds counted
  def total(list), do: Enum.sum(list)

  # Counts the number of "busy" days (5 or more birds)
  def busy_days(list), do: Enum.count(list, fn count -> count >= 5 end)
end

