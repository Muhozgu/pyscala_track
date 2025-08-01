defmodule GuessingGame do
  # Task 5: Handle the case when no guess is supplied and the argument is just the secret_number
  def compare(secret_number), do: compare(secret_number, :no_guess)

  def compare(secret_number, :no_guess), do: "Make a guess"
  def compare(secret_number, nil), do: "Make a guess"

  def compare(secret_number, guess) do
    cond do
      guess == secret_number ->
        "Correct"

      abs(secret_number - guess) == 1 ->
        "So close"

      guess > secret_number ->
        "Too high"

      guess < secret_number ->
        "Too low"
    end
  end
end



