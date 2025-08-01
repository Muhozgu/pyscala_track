defmodule EliudsEggs do
  @doc """
  Given the number, count the number of eggs.
  """
  @spec egg_count(number :: integer()) :: non_neg_integer()
  def egg_count(number) do
    for(<<bit::1 <- :binary.encode_unsigned(number)>>, do: bit) |> Enum.sum
  end
end