defmodule BasketballWebsite do
  # Task 1: Recursive approach (manual traversal)
  def extract_from_path(data, path) do
    keys = String.split(path, ".")
    do_extract(data, keys)
  end

  defp do_extract(nil, _), do: nil
  defp do_extract(data, []), do: data

  defp do_extract(%{} = data, [key | rest]) do
    case Map.get(data, key) do
      nil -> nil
      value -> do_extract(value, rest)
    end
  end

  defp do_extract(_, _), do: nil

  # Task 2: Refactored approach using Kernel.get_in/2
  def get_in_path(data, path) do
    keys = String.split(path, ".")
    get_in(data, keys)
  end
end