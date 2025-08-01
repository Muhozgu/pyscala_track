defmodule SgfParsing do
  defmodule Sgf do
    defstruct properties: %{}, children: []
  end

  @type sgf :: %Sgf{properties: map, children: [sgf]}

  @doc """
  Parse a string into a Smart Game Format tree
  """
  @spec parse(encoded :: String.t()) :: {:ok, sgf} | {:error, String.t()}
  def parse(""), do: {:error, "tree missing"}
  def parse(";"), do: {:error, "tree missing"}
  def parse("()"), do: {:error, "tree with no nodes"}
  def parse(encoded) do
    # handle special characters immediately
    encoded = preparse(encoded)
    try do
      [root] = Regex.run(~r/^\((;.*)\)$/, encoded, capture: :all_but_first)
      {:ok, parse_subtree(root) |> build_tree()}
    catch
      error -> {:error, error}
    end
  end

  # the right way to handle this is to build out a full-scale
  # lexical parser, but that would be overkill for this exercise -
  # on the other hand, a handful of inscrutable regular expressions
  # is hard to understand and maintain, so let's find a middle ground

  defp preparse(str), do: str
    # start with tabs and newlines
    |> String.replace(~r/\\\t/, " ")
    |> String.replace(~r/\\\n/, "")
    |> String.replace(~r/\\t/, "t")
    |> String.replace(~r/\\n/, "n")
    |> String.replace(~r/\t/, " ")
    # characters that need to be preserved: unescaped newlines,
    # escaped backslashes, and delimiters occurring within node properties
    |> String.replace(~r/\n/, "{{NL}}")
    |> String.replace(~r/\[(\w+);/, "[\\1{{SC}}")
    |> String.replace(~r/\[(\w+)\((\w+)\)/, "[\\1{{OP}}\\2{{CP}}")
    |> String.replace("\\\\", "{{BS}}")
    |> String.replace(~r/\[(\w+)\[/, "[\\1\\[")
    |> String.replace(~r/\\\[/, "{{LB}}")
    |> String.replace(~r/\\\]/, "{{RB}}")

  defp build_tree({props, children}) do
    %Sgf{properties: props, children: Enum.map(children, &build_tree/1)}
  end

  defp scan_tree(vals, pat) do
    Regex.scan(pat, vals, capture: :all_but_first) |> List.flatten
  end

  defp parse_subtree(tree) do
    # non-greedy matching of anything starting with a semicolon
    # and ending at a semicolon, open paren, or end of string,
    # but not when preceded by an open paren (those are in variations)
    [node | children] = scan_tree(tree, ~r"(?<!\();(.*?(?=[(;]|$))")
    node = parse_node(node)
    children = Enum.map(children, &{parse_node(&1), []})
    # we can get away with a stricter regex for parenthetical variations
    variations = scan_tree(tree, ~r/\((;[A-Z]+\[[[:alnum:]]\]+)\)/)
      |> Enum.map(&parse_subtree/1)
    {node, variations ++ children}
  end

  defp parse_node(node_props) do
    # this builds a list of the form ["A", "[b]", "C", "[d]"]
    props = Regex.split(~r/(\w+?(?=\[|$))/, node_props,
            trim: true, include_captures: true)
    segs = Enum.chunk_every(props, 2)  # [prop, vals]
    cond do
      rem(length(props), 2) !== 0 -> throw "properties without delimiter"
      invalid_prop_names?(segs) -> throw "property must be in uppercase"
      true -> Enum.reduce(segs, %{}, fn [prop, vals], acc ->
        values = scan_tree(vals, ~r/\[(.+?)\]/) |> Enum.map(&unescape/1)
        Map.put(acc, prop, values)
      end)
    end
  end

  defp invalid_prop_names?(props) do
    Enum.map(props, &hd/1) |> Enum.any?(&(String.upcase(&1) != &1))
  end

  defp unescape(str), do: str
    |> String.replace("{{NL}}", "\n")
    |> String.replace("{{SC}}", ";")
    |> String.replace("{{OP}}", "(")
    |> String.replace("{{CP}}", ")")
    |> String.replace("{{BS}}", "\\")
    |> String.replace("{{LB}}", "[")
    |> String.replace("{{RB}}", "]")
end
