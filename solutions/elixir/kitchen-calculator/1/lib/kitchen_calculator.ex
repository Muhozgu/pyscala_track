defmodule KitchenCalculator do
  @conversion_map %{
    milliliter: 1,
    cup: 240,
    fluid_ounce: 30,
    teaspoon: 5,
    tablespoon: 15
  }

  # Gets only the numeric volume from a volume pair like {:cup, 2}
  def get_volume({_unit, volume}) do
    volume
  end

  # Converts any unit to milliliters
  def to_milliliter({unit, volume}) do
    factor = Map.fetch!(@conversion_map, unit)
    {:milliliter, volume * factor}
  end

  # Converts milliliters to a target unit
  def from_milliliter({:milliliter, volume}, target_unit) do
    factor = Map.fetch!(@conversion_map, target_unit)
    {target_unit, volume / factor}
  end

  # Convert from any unit to any other unit using milliliters as intermediate
  def convert(volume_pair, target_unit) do
    volume_pair
    |> to_milliliter()
    |> from_milliliter(target_unit)
  end
end


