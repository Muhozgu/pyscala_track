defmodule LibraryFees do
  @spec datetime_from_string(String.t()) :: NaiveDateTime.t()
  def datetime_from_string(string) do
    NaiveDateTime.from_iso8601!(string)
  end

  @spec before_noon?(NaiveDateTime.t()) :: boolean()
  def before_noon?(datetime) do
    datetime.hour < 12
  end

  @spec return_date(NaiveDateTime.t()) :: Date.t()
  def return_date(checkout_datetime) do
    days_to_add = if before_noon?(checkout_datetime), do: 28, else: 29
    NaiveDateTime.to_date(NaiveDateTime.add(checkout_datetime, days_to_add * 86400))
  end

  @spec days_late(Date.t(), NaiveDateTime.t()) :: non_neg_integer()
  def days_late(planned_return_date, actual_return_datetime) do
    actual_return_date = NaiveDateTime.to_date(actual_return_datetime)
    days = Date.diff(actual_return_date, planned_return_date)
    max(days, 0)
  end

  @spec monday?(NaiveDateTime.t()) :: boolean()
  def monday?(datetime) do
    datetime
    |> NaiveDateTime.to_date()
    |> Date.day_of_week() == 1
  end

  @spec calculate_late_fee(String.t(), String.t(), integer()) :: integer()
  def calculate_late_fee(checkout, return, rate) do
    checkout_dt = datetime_from_string(checkout)
    return_dt = datetime_from_string(return)
    due_date = return_date(checkout_dt)
    late_days = days_late(due_date, return_dt)

    fee = late_days * rate
    if monday?(return_dt), do: div(fee, 2), else: fee
  end
end

