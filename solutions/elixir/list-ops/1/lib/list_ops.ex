defmodule ListOps do
  # Please don't use any external modules (especially List or Enum) in your
  # implementation. The point of this exercise is to create these basic
  # functions yourself. You may use basic Kernel functions (like `Kernel.+/2`
  # for adding numbers), but please do not use Kernel functions for Lists like
  # `++`, `--`, `hd`, `tl`, `in`, and `length`.

  @type acc :: any

  @spec count(list) :: non_neg_integer
  def count(l), do: count(l, 0)

  defp count([], acc), do: acc
  defp count([_head | tail], acc), do: count(tail, acc + 1)

  @spec reverse(list) :: list
  def reverse(l), do: reverse(l, [])

  defp reverse([], acc), do: acc
  defp reverse([head | tail], acc), do: reverse(tail, [head | acc])

  @spec map(list, (any -> any)) :: list
  def map(l, f), do: map(l, f, [])

  defp map([], _f, acc), do: reverse(acc)
  defp map([head | tail], f, acc), do: map(tail, f, [f.(head) | acc])

  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter(l, f), do: filter(l, f, [])

  defp filter([], _f, acc), do: reverse(acc)

  defp filter([head | tail], f, acc) do
    if f.(head) do
      filter(tail, f, [head | acc])
    else
      filter(tail, f, acc)
    end
  end

  @spec foldl(list, acc, (any, acc -> acc)) :: acc
  def foldl([], acc, _f), do: acc
  def foldl([head | tail], acc, f), do: foldl(tail, f.(head, acc), f)

  @spec foldr(list, acc, (any, acc -> acc)) :: acc
  def foldr(list, acc, fun), do: reverse(list) |> foldl(acc, fun)

  @spec append(list, list) :: list
  def append(a, b), do: append([], b, reverse(a))

  defp append([], [], acc), do: reverse(acc)
  defp append([], [head | tail], acc), do: append([], tail, [head | acc])

  @spec concat([[any]]) :: [any]
  def concat(lists) do
    fun = &[&1 | &2]

    lists
    |> foldl([], &foldl(&1, &2, fun))
    |> reverse()
  end
end
