defmodule Knapsack do
  @moduledoc false

  @doc """
  Return the maximum value that a knapsack can carry.
  """
  @spec maximum_value(items :: [%{value: integer, weight: integer}], maximum_weight :: integer) ::
          integer
  def maximum_value(items, maximum_weight),
    do: solve(items, maximum_weight, 0, 0)

  # Below is an adapted solution, originally taken from:
  # https://rosettacode.org/wiki/Knapsack_problem/0-1#Elixir
  #
  # We do a nice trick on reducing number of computations by comparing the
  # total values of tail-only collection of items (and skipping a head) or
  # full collection of them taken into knapsack; see last clause of `solve/4`.
  #
  # P.S. Initial bruteforce approach with all permutations would take
  # exponential time to solve test with more than 8 items.

  defp solve([], _, value, _),
    do: value

  defp solve([%{weight: w} | tail], limit, value, weight) when w > limit,
    do: solve(tail, limit, value, weight)

  defp solve([%{value: v, weight: w} | tail], limit, value, weight) do
    tail_value = solve(tail, limit, value, weight)
    head_value = solve(tail, limit - w, value + v, weight + w)

    if tail_value > head_value, do: tail_value, else: head_value
  end
end