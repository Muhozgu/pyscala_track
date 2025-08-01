defmodule GameOfLife do
  @moduledoc false

  @doc """
  Apply the rules of Conway's Game of Life to a grid of cells
  """
  @spec tick(matrix :: list(list(0 | 1))) :: list(list(0 | 1))
  def tick([]), do: []

  def tick(matrix) do
    matrix
    |> to_generation()
    |> next_generation()
    |> to_matrix()
  end

  # Converts the given list of lists into a Map with keys as {x, y} coordinates.
  #
  # This will simplify live neighbors counting process. Along the way we also collect some meta
  # info: maximum X and maximum Y.
  defp to_generation(matrix) do
    matrix
    |> Enum.with_index()
    |> Enum.reduce(%{max_y: 0, max_x: 0}, fn {row, y}, generation_acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(generation_acc, fn {el, x}, generation_acc ->
        generation_acc
        |> Map.put({x, y}, el)
        |> Map.update(:max_y, y, fn my -> if my < y, do: y, else: my end)
        |> Map.update(:max_x, x, fn mx -> if mx < x, do: x, else: mx end)
      end)
    end)
  end

  # Goes over the given field, cell by cell, checks all cell's neighbors and updates according to
  # the Game of Life rules.
  defp next_generation(%{max_y: my, max_x: mx} = generation) do
    Enum.reduce(0..my, generation, fn y, new_generation ->
      Enum.reduce(0..mx, new_generation, fn x, new_generation ->
        coord = {x, y}

        cell = Map.get(generation, coord)
        next_cell = coord |> count_live_neibs(generation) |> next_cell(cell)

        Map.put(new_generation, coord, next_cell)
      end)
    end)
  end

  # Counts all live neighbors for a given X and Y (horizontal, vertical, or diagonal; of course,
  # excluding the origin cell itself).
  defp count_live_neibs({x, y}, generation) do
    for row <- (y - 1)..(y + 1),
        col <- (x - 1)..(x + 1),
        not (row == y and col == x),
        reduce: 0 do
      total_live -> total_live + Map.get(generation, {col, row}, 0)
    end
  end

  # Decides what will be the next cell. Rules are simple enough:
  #
  # - Any live cell with two or three live neighbors lives on
  # - Any dead cell with exactly three live neighbors becomes a live cell
  # - All other cells die or stay dead
  defp next_cell(live_n, 1) when live_n in [2, 3], do: 1
  defp next_cell(3, 0), do: 1
  defp next_cell(_, _), do: 0

  # Provides an opposite conversion from the intermediary Map structure to a list of lists.
  defp to_matrix(%{max_y: my, max_x: mx} = field) do
    Enum.map(0..my, fn y ->
      Enum.map(0..mx, fn x ->
        Map.get(field, {x, y})
      end)
    end)
  end
end