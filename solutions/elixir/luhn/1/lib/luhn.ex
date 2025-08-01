defmodule Luhn do
  @doc """
  Checks if the given number is valid via the luhn formula
  """
  @spec valid?(String.t()) :: boolean
  def valid?(number) do
    number
    |> to_charlist
    |> Enum.reverse
    |> get_checksum(0, 0)
    |> to_result
  end

  @spec to_result(:invalid | {non_neg_integer(), non_neg_integer()}) :: boolean()
  defp to_result(:invalid), do: false
  defp to_result({checksum, char_count}) when char_count > 1 do
    rem(checksum, 10) == 0
  end
  defp to_result(_checksum), do: false

  @spec get_checksum([char()], non_neg_integer(), non_neg_integer()) :: {non_neg_integer(), non_neg_integer()} | :invalid
  defp get_checksum([], count, acc), do: {acc, count}
  defp get_checksum([next_char | rest], count, acc) do
    case add_value(next_char, count) do
      :invalid -> :invalid
      {value, next_count} -> get_checksum(rest, next_count, value + acc)
    end 
  end

  @spec add_value(char(), non_neg_integer()) :: {non_neg_integer(), non_neg_integer()} | :error
  defp add_value(?\s, count), do: {0, count}
  defp add_value(next_char, count) when next_char in ?0..?9 and rem(count, 2) == 0 do
    {next_char - ?0, count+1}
  end
  defp add_value(next_char, count) when next_char in ?0..?9 do
    {normalize((next_char - ?0) * 2), count+1}
  end
  defp add_value(_other_char, _count), do: :invalid

  @spec normalize(integer()) :: integer()
  defp normalize(value) when value > 9, do: value - 9
  defp normalize(value), do: value
end