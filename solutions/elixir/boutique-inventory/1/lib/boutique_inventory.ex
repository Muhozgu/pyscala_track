defmodule BoutiqueInventory do
  # Sorts the inventory by the item's price in ascending order
  def sort_by_price(inventory) do
    Enum.sort_by(inventory, & &1.price)
  end

  # Returns only items where the price is missing (i.e., nil)
  def with_missing_price(inventory) do
    Enum.filter(inventory, &is_nil(&1.price))
  end

  # Updates each item's name by replacing old_word with new_word
  def update_names(inventory, old_word, new_word) do
    Enum.map(inventory, fn item ->
      Map.update!(item, :name, fn name ->
        String.replace(name, old_word, new_word)
      end)
    end)
  end

  # Increases the quantity for each size of the given item by count
  def increase_quantity(item, count) do
    updated_quantities = Enum.map(item.quantity_by_size, fn {size, qty} ->
      {size, qty + count}
    end)
    %{item | quantity_by_size: Map.new(updated_quantities)}
  end

  # Returns the total quantity across all sizes for the item
  def total_quantity(item) do
    item.quantity_by_size
    |> Map.values()
    |> Enum.sum()
  end
end
