defmodule RPG.CharacterSheet do
  def welcome() do
    IO.puts("Welcome! Let's fill out your character sheet together.")
    :ok
  end

  def ask_name() do
    IO.puts("What is your character's name?")
    IO.gets("") |> String.trim()
  end

  def ask_class() do
    IO.puts("What is your character's class?")
    IO.gets("") |> String.trim()
  end

  def ask_level() do
    IO.puts("What is your character's level?")
    IO.gets("") |> String.trim() |> String.to_integer()
  end

  def run() do
    welcome()
    name = ask_name()
    class = ask_class()
    level = ask_level()

    character = %{name: name, class: class, level: level}
    IO.inspect(character, label: "Your character")
    character
  end
end

