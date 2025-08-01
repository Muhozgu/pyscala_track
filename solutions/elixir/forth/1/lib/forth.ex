defmodule Evaluator do
  @type stack :: [integer()]
  @type operation :: (stack -> {:ok, stack} | {:error, atom()})
  @type definitions :: %{String.t() => [operation]}

  @type t :: %__MODULE__{definitions: definitions, stack: stack}
  defstruct definitions: %{
              "+" => [&__MODULE__.add/1],
              "-" => [&__MODULE__.subtract/1],
              "*" => [&__MODULE__.multiply/1],
              "/" => [&__MODULE__.divide/1],
              "DUP" => [&__MODULE__.duplicate/1],
              "DROP" => [&__MODULE__.drop/1],
              "SWAP" => [&__MODULE__.swap/1],
              "OVER" => [&__MODULE__.over/1]
            },
            stack: []

  @spec add(stack) :: {:ok, stack} | {:error, :stack_underflow}
  def add([h1, h2 | t]), do: {:ok, [h2 + h1 | t]}
  def add(_), do: {:error, :stack_underflow}

  @spec subtract(stack) :: {:ok, stack} | {:error, :stack_underflow}
  def subtract([h1, h2 | t]), do: {:ok, [h2 - h1 | t]}
  def subtract(_), do: {:error, :stack_underflow}

  @spec multiply(stack) :: {:ok, stack} | {:error, :stack_underflow}
  def multiply([h1, h2 | t]), do: {:ok, [h2 * h1 | t]}
  def multiply(_), do: {:error, :stack_underflow}

  @spec divide(stack) :: {:ok, stack} | {:error, :stack_underflow | :division_by_zero}
  def divide([0, _ | _]), do: {:error, :division_by_zero}
  def divide([h1, h2 | t]), do: {:ok, [div(h2, h1) | t]}
  def divide(_), do: {:error, :stack_underflow}

  @spec duplicate(stack) :: {:ok, stack} | {:error, :stack_underflow}
  def duplicate([h | t]), do: {:ok, [h, h | t]}
  def duplicate(_), do: {:error, :stack_underflow}

  @spec drop(stack) :: {:ok, stack} | {:error, :stack_underflow}
  def drop([_ | t]), do: {:ok, t}
  def drop(_), do: {:error, :stack_underflow}

  @spec swap(stack) :: {:ok, stack} | {:error, :stack_underflow}
  def swap([h1, h2 | t]), do: {:ok, [h2, h1 | t]}
  def swap(_), do: {:error, :stack_underflow}

  @spec over(stack) :: {:ok, stack} | {:error, :stack_underflow}
  def over([h1, h2 | t]), do: {:ok, [h2, h1, h2 | t]}
  def over(_), do: {:error, :stack_underflow}

  @spec add_stack_as_operation(stack) :: [operation]
  def add_stack_as_operation(old_stack),
    do: [fn new_stack -> {:ok, new_stack |> Kernel.++(old_stack) |> Enum.reverse()} end]

  @spec tokens_to_operations([String.t()], t()) :: stack
  def tokens_to_operations(tokens, ev),
    do: Enum.reduce(tokens, [], &(ev.definitions[to_word(&1)] ++ &2)) |> Enum.reverse()

  @spec to_word(String.t()) :: String.t()
  def to_word(str), do: String.upcase(str)
end





defmodule Forth do
  alias Evaluator

  @opaque evaluator :: Evaluator.t()

  @definition_start ":"
  @definition_end ";"

  @doc """
  Create a new evaluator.
  """
  @spec new() :: evaluator
  def new(), do: %Evaluator{}

  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  @spec eval(evaluator, String.t()) :: evaluator
  def eval(ev, s) do
    s |> String.split(~r/#{@definition_end}/, trim: true) |> Enum.reduce(ev, &eval_statement/2)
  end

  defp eval_statement(statement, ev) do
    with {:ok, new_ev} <- statement |> tokens() |> eval_tokens(ev) do
      new_ev
    else
      {:error, :stack_underflow} -> raise Forth.StackUnderflow
      {:error, :invalid_word} -> raise Forth.InvalidWord
      {:error, :unknown_word} -> raise Forth.UnknownWord
      {:error, :division_by_zero} -> raise Forth.DivisionByZero
    end
  end

  defp tokens(statement), do: statement |> String.trim() |> String.split(~r/[\s|[:cntrl:]]/u)

  defp eval_tokens(tokens, ev)
  defp eval_tokens([], ev), do: {:ok, Map.update!(ev, :stack, &Enum.reverse/1)}

  defp eval_tokens([@definition_start, word | tokens], ev),
    do: if(number?(word), do: {:error, :invalid_word}, else: {:ok, define(word, tokens, ev)})

  defp eval_tokens([h | t], ev) do
    word = Evaluator.to_word(h)

    cond do
      number?(word) ->
        eval_tokens(t, Map.update!(ev, :stack, &[String.to_integer(word) | &1]))

      Map.has_key?(ev.definitions, word) ->
        with {:ok, new_ev} <- apply_definition(word, ev), do: eval_tokens(t, new_ev)

      true ->
        {:error, :unknown_word}
    end
  end

  defp define(word, tokens, ev) do
    eval_tokens(tokens, ev)
    |> get_operations(tokens, ev)
    |> then(&put_in(ev, [Access.key(:definitions), Access.key(Evaluator.to_word(word))], &1))
  end

  defp apply_definition(word, ev) do
    Enum.reduce_while(ev.definitions[word], {:ok, ev}, fn fun, {:ok, acc} ->
      with {:ok, new_stack} <- fun.(acc.stack) do
        {:cont, {:ok, %{acc | stack: new_stack}}}
      else
        error -> {:halt, error}
      end
    end)
  end

  defp get_operations({:ok, ev}, _, _), do: Evaluator.add_stack_as_operation(ev.stack)

  defp get_operations({:error, :stack_underflow}, tokens, ev),
    do: Evaluator.tokens_to_operations(tokens, ev)

  defp number?(str), do: str =~ ~r/-?\d+/

  @doc """
  Return the current stack as a string with the element on top of the stack
  being the rightmost element in the string.
  """
  @spec format_stack(evaluator) :: String.t()
  def format_stack(ev) do
    Enum.reduce(ev.stack, [], &[Integer.to_string(&1) | &2]) |> Enum.reverse() |> Enum.join(" ")
  end

  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end
