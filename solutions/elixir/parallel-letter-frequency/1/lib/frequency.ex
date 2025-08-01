defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, workers) do
    letters =
      Enum.join(texts)
      |> String.replace(~r/[^\p{L}]/u, "")
      |> String.downcase()
      |> String.graphemes()

    letters
    |> Enum.chunk_every(div(length(letters), workers) + 1)
    |> Task.async_stream(&calculate_frequency(&1, %{}))
    |> Enum.reduce(%{}, fn {:ok, result_part}, total_result ->
      Map.merge(total_result, result_part, fn _, v1, v2 -> v1 + v2 end)
    end)
  end

  defp calculate_frequency([], result), do: result

  defp calculate_frequency([h | t], result) do
    calculate_frequency(t, Map.update(result, h, 1, &(&1 + 1)))
  end
end
