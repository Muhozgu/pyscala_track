defmodule RelativeDistance do
  @doc """
  Find the degree of separation of two members given a given family tree.
  """
  @spec degree_of_separation(
          family_tree :: %{String.t() => [String.t()]},
          person_a :: String.t(),
          person_b :: String.t()
        ) :: nil | pos_integer()
  def degree_of_separation(family_tree, person_a, person_b) do
    if person_a == person_b do
      0
    else
      family_tree
      |> build_graph()
      |> shortest_path(person_a, person_b)
    end
  end

  defp build_graph(family_tree) do
    all_people = extract_all_people(family_tree)

    empty_graph = Map.new(all_people, &{&1, []})

    Enum.reduce(family_tree, empty_graph, fn {parent, children}, graph ->
      with_parent_child = add_parent_child_connections(graph, parent, children)

      if length(children) > 1 do
        add_sibling_connections(with_parent_child, children)
      else
        with_parent_child
      end
    end)
  end

  defp extract_all_people(family_tree) do
    Enum.reduce(family_tree, MapSet.new(), fn {parent, children}, acc ->
      acc
      |> MapSet.put(parent)
      |> MapSet.union(MapSet.new(children))
    end)
    |> MapSet.to_list()
  end

  defp add_parent_child_connections(graph, parent, children) do
    with_parent_to_children =
      Map.update!(graph, parent, &(&1 ++ children))

    Enum.reduce(children, with_parent_to_children, fn child, acc ->
      Map.update!(acc, child, &[parent | &1])
    end)
  end

  defp add_sibling_connections(graph, siblings) do
    Enum.reduce(siblings, graph, fn sibling, acc ->
      other_siblings = Enum.filter(siblings, &(&1 != sibling))
      Map.update!(acc, sibling, &(&1 ++ other_siblings))
    end)
  end

  defp shortest_path(graph, start, target) do
    initial_queue = [{start, 0}]
    initial_visited = MapSet.new([start])

    search(graph, initial_queue, initial_visited, target)
  end

  defp search(_graph, [], _visited, _target), do: nil

  defp search(graph, [{node, distance} | rest], visited, target) do
    if node == target do
      distance
    else
      connections = Map.get(graph, node, [])

      {new_queue, new_visited} =
        Enum.reduce(connections, {rest, visited}, fn neighbor, {queue, seen} ->
          if MapSet.member?(seen, neighbor) do
            {queue, seen}
          else
            {queue ++ [{neighbor, distance + 1}], MapSet.put(seen, neighbor)}
          end
        end)

      search(graph, new_queue, new_visited, target)
    end
  end
end
