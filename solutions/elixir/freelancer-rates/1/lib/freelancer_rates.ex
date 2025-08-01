defmodule FreelancerRates do
 @billable_days_per_month 22

  def daily_rate(hourly_rate) do
    # Please implement the daily_rate/1 function
    hourly_rate * 8.0
  end

   def apply_discount(before_discount, discount) do
    before_discount * (1 - discount / 100)
  end

  def monthly_rate(hourly_rate, discount) do
  daily = daily_rate(hourly_rate)
  discounted = apply_discount(daily, discount)
  discounted * @billable_days_per_month
  |> Float.ceil()
  |> trunc()
end

  def days_in_budget(budget, hourly_rate, discount) do
    daily = daily_rate(hourly_rate)
    discounted = apply_discount(daily, discount)
    Float.floor(budget / discounted, 1)
  end
end


FreelancerRates.daily_rate(60)
FreelancerRates.apply_discount(150, 10)
FreelancerRates.monthly_rate(77, 10.5)
FreelancerRates.days_in_budget(20000, 80, 11.0)