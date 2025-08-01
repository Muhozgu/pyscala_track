defmodule WineCellar do
  def explain_colors do
    [
      white: "Fermented without skin contact.",
      red: "Fermented with skin contact using dark-colored grapes.",
      rose: "Fermented with some skin contact, but not enough to qualify as a red wine."
    ]
  end

  def filter(cellar, color, opts \\ []) do
    # Filter by color to get all wines of the given color
    filtered_by_color = Enum.filter(cellar, fn {c, _} -> c == color end)

    # Apply the year filter if provided in opts
    filtered_by_year = apply_filters(filtered_by_color, opts, :year, &filter_by_year/2)

    # Apply the country filter if provided in opts
    filtered_by_country = apply_filters(filtered_by_year, opts, :country, &filter_by_country/2)

    # Return the list of filtered wines (extracting the wine details)
    Enum.map(filtered_by_country, fn {_, wine} -> wine end)
  end

  # Helper function to apply filters by year, country, etc.
  defp apply_filters(wines, opts, key, filter_fn) do
    case Keyword.get(opts, key) do
      nil -> wines
      value -> filter_fn.(wines, value)
    end
  end

  # Filter wines by year
  defp filter_by_year(wines, year) do
    Enum.filter(wines, fn {_, {_, y, _}} -> y == year end)
  end

  # Filter wines by country
  defp filter_by_country(wines, country) do
    Enum.filter(wines, fn {_, {_, _, c}} -> c == country end)
  end
end
