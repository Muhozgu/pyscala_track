defmodule PhoneNumber do
  @doc """
  Remove formatting from a phone number if the given number is valid. Return an error otherwise.
  """
  @spec clean(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def clean(raw) do
    digits = String.replace(raw, ~r/\D/, "")

    cond do
      String.match?(raw, ~r/[^\d-(). +]/) ->
        error("must contain digits only")

      String.length(digits) > 11 ->
        error("must not be greater than 11 digits")

      String.length(digits) < 10 ->
        error("must not be fewer than 10 digits")

      String.length(digits) == 11 and !String.starts_with?(digits, "1") ->
        error("11 digits must start with 1")

      String.at(digits, -10) == "0" ->
        error("area code cannot start with zero")

      String.at(digits, -10) == "1" ->
        error("area code cannot start with one")

      String.at(digits, -7) == "0" ->
        error("exchange code cannot start with zero")

      String.at(digits, -7) == "1" ->
        error("exchange code cannot start with one")

      true ->
        ok(String.slice(digits, -10, 10))
    end
  end

  defp error(message), do: {:error, message}
  defp ok(result), do: {:ok, result}
end