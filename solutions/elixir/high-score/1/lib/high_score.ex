defmodule HighScore do
  # Initializes a new score map
  def new(), do: %{}

  # Adds a player and their score to the map
  def add_player(scores, name, score \\ 0) do
    Map.put(scores, name, score)
  end

  # Removes a player from the map
  def remove_player(scores, name) do
    Map.delete(scores, name)
  end

  # Resets a player's score to 0
  def reset_score(scores, name) do
    Map.put(scores, name, 0)
  end

  # Updates a player's score by adding to the existing score
  def update_score(scores, name, score) do
    Map.update(scores, name, score, fn existing -> existing + score end)
  end

  # Returns the list of player names
  def get_players(scores) do
    Map.keys(scores)
  end
end
