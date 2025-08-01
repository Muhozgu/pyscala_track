defmodule SwiftScheduling do
  @doc """
  Convert delivery date descriptions to actual delivery dates, based on when the meeting started.
  """
  @spec delivery_date(NaiveDateTime.t(), String.t()) :: NaiveDateTime.t()
  def delivery_date(meeting_date, "NOW") do
    NaiveDateTime.add(meeting_date, 2, :hour)
  end

  def delivery_date(meeting_date, "ASAP") when meeting_date.hour < 13 do
    %{meeting_date | hour: 17, minute: 0}
  end

  def delivery_date(meeting_date, "ASAP") when meeting_date.hour >= 13 do
    NaiveDateTime.add(%{meeting_date | hour: 13, minute: 0}, 1, :day)
  end

  def delivery_date(meeting_date, "EOW") do
    d = NaiveDateTime.to_date(meeting_date)
    dow = Date.day_of_week(d)

    if dow <= 3 do
      NaiveDateTime.add(%{meeting_date | hour: 17, minute: 0}, 5 - dow, :day)
    else
      NaiveDateTime.add(%{meeting_date | hour: 20, minute: 0}, 7 - dow, :day)
    end
  end

  def delivery_date(meeting_date, description) do
    cond do
      Regex.match?(~r"(\d+)M", description) -> handle_months(meeting_date, description)
      Regex.match?(~r"Q(\d+)", description) -> handle_quarter(meeting_date, description)
      true -> {:error, "invalid description"}
    end
  end

  defp handle_months(meeting_date, description) do
    [_, d] = Regex.run(~r"(\d+)M", description)
    {i, _} = Integer.parse(d)
    cd = NaiveDateTime.to_date(meeting_date)
    m = cd.month

    if m < i do
      nd = NaiveDateTime.new!(meeting_date.year, i, 1, 8, 0, 0)

      cond do
        Date.day_of_week(nd) == 6 -> NaiveDateTime.shift(nd, day: 2)
        Date.day_of_week(nd) == 7 -> NaiveDateTime.shift(nd, day: 1)
        true -> nd
      end
    else
      nd = NaiveDateTime.new!(meeting_date.year + 1, i, 1, 8, 0, 0)

      cond do
        Date.day_of_week(nd) == 6 -> NaiveDateTime.shift(nd, day: 2)
        Date.day_of_week(nd) == 7 -> NaiveDateTime.shift(nd, day: 1)
        true -> nd
      end
    end
  end

  defp handle_quarter(meeting_date, description) do
    [_, d] = Regex.run(~r"Q(\d+)", description)
    {i, _} = Integer.parse(d)
    q = Date.quarter_of_year(meeting_date)

    if q <= i do
      nd = Date.end_of_month(Date.new!(meeting_date.year, i * 3, 1))
      ndt = NaiveDateTime.new!(nd.year, nd.month, nd.day, 8, 0, 0)

      cond do
        Date.day_of_week(ndt) == 7 -> NaiveDateTime.shift(ndt, day: -2)
        Date.day_of_week(ndt) == 6 -> NaiveDateTime.shift(ndt, day: -1)
        true -> ndt
      end
    else
      nd = Date.end_of_month(Date.new!(meeting_date.year + 1, i * 3, 1))
      ndt = NaiveDateTime.new!(nd.year, nd.month, nd.day, 8, 0, 0)

      cond do
        Date.day_of_week(ndt) == 7 -> NaiveDateTime.shift(ndt, day: -2)
        Date.day_of_week(ndt) == 6 -> NaiveDateTime.shift(ndt, day: -1)
        true -> ndt
      end
    end
  end
end