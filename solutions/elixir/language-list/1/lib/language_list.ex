defmodule LanguageList do
  # Returns a new (empty) list
  def new() do
    []
  end

  # Adds a language to the front of the list
  def add(list, language) do
    [language | list]
  end

  # Removes the first element from the list
  def remove([_head | tail]) do
    tail
  end

  # Returns the first element of the list
  def first([head | _tail]) do
    head
  end

  # Returns the number of elements in the list
  def count(list) do
    length(list)
  end

  # Returns true if "Elixir" is in the list, false otherwise
  def functional_list?(list) do
    "Elixir" in list
  end
end

