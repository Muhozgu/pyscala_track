defmodule Match do
  @regex ~r/^(?<team_a>[ \w]+);(?<team_b>[ \w]+);(?<result>win|loss|draw)$/

  @enforce_keys [:team_a, :team_b, :winner]
  defstruct [:team_a, :team_b, :winner]

  @typep winner :: :team_a | :team_b | :draw
  @type t :: %__MODULE__{team_a: String.t(), team_b: String.t(), winner: winner}

  @spec new(binary) :: {:ok, t} | {:error, :invalid_result}
  def new(match_str) do
    case Regex.named_captures(@regex, match_str) do
      %{"team_a" => team_a, "team_b" => team_b, "result" => result} ->
        {:ok, %__MODULE__{team_a: team_a, team_b: team_b, winner: winner(result)}}

      _ ->
        {:error, :invalid_result}
    end
  end

  defp winner("win"), do: :team_a
  defp winner("draw"), do: :draw
  defp winner("loss"), do: :team_b
end





defmodule Team do
  @enforce_keys [:name]
  defstruct [:name, played: 0, won: 0, drawn: 0, lost: 0, points: 0]

  @type t :: %__MODULE__{
          name: String.t(),
          played: integer(),
          won: integer(),
          drawn: integer(),
          lost: integer(),
          points: integer()
        }

  defguardp won_as_team_a(team, match) when team.name == match.team_a and match.winner == :team_a
  defguardp won_as_team_b(team, match) when team.name == match.team_b and match.winner == :team_b

  @spec new(String.t()) :: Team.t()
  def new(name), do: %__MODULE__{name: name}

  @spec new(String.t(), Match.t()) :: t
  def new(team, match), do: team |> new() |> tally(match)

  @spec tally(t, Match.t()) :: t
  def tally(team, match) when won_as_team_a(team, match) or won_as_team_b(team, match),
    do: %{team | played: team.played + 1, won: team.won + 1, points: team.points + 3}

  def tally(team, %{winner: :draw}),
    do: %{team | played: team.played + 1, drawn: team.drawn + 1, points: team.points + 1}

  def tally(team, _), do: %{team | played: team.played + 1, lost: team.lost + 1}
end





defmodule Tournament do
  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """
  @spec tally(input :: list(String.t())) :: String.t()
  def tally(input), do: input |> Enum.reduce(%{}, &add_scores/2) |> print()

  defp add_scores(match_str, all_results) do
    case Match.new(match_str) do
      {:ok, match} -> score_match(all_results, match)
      {:error, _} -> all_results
    end
  end

  defp score_match(all_results, match),
    do: all_results |> score_team(match.team_a, match) |> score_team(match.team_b, match)

  defp score_team(all_results, name, match),
    do: Map.update(all_results, name, Team.new(name, match), &Team.tally(&1, match))

  defp print(scores) do
    scores
    |> Map.values()
    |> Enum.sort_by(& &1.points, :desc)
    |> then(&[header() | &1])
    |> Enum.map_join("\n", &to_row/1)
  end

  defp to_row(value) when is_binary(value), do: value

  defp to_row(%Team{} = team) do
    header_row(team.name) <>
      cell(team.played) <>
      cell(team.won) <>
      cell(team.drawn) <>
      cell(team.lost) <>
      cell(team.points)
  end

  defp cell(value) when is_integer(value), do: value |> Integer.to_string() |> cell()
  defp cell(value), do: " | " <> String.pad_leading(value, 2)

  defp header_row(name), do: String.pad_trailing(name, 30)

  defp header(),
    do: header_row("Team") <> cell("MP") <> cell("W") <> cell("D") <> cell("L") <> cell("P")
end