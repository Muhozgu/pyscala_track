defmodule RPG do
  defmodule Character do
    defstruct health: 100, mana: 0
  end

  defmodule LoafOfBread do
    defstruct []
  end

  defmodule ManaPotion do
    defstruct strength: 10
  end

  defmodule Poison do
    defstruct []
  end

  defmodule EmptyBottle do
    defstruct []
  end

  # Step 1: Define edibility protocol
  defprotocol Edible do
    @doc """
    Takes an item and a character, returns a tuple of {byproduct, updated_character}
    """
    def eat(item, character)
  end

  # Step 2: LoafOfBread implementation
  defimpl Edible, for: LoafOfBread do
    def eat(_loaf, %Character{} = character) do
      updated_character = %Character{character | health: character.health + 5}
      {nil, updated_character}
    end
  end

  # Step 3: ManaPotion implementation
  defimpl Edible, for: ManaPotion do
    def eat(%ManaPotion{strength: strength}, %Character{} = character) do
      updated_character = %Character{character | mana: character.mana + strength}
      {%EmptyBottle{}, updated_character}
    end
  end

  # Step 4: Poison implementation (updated)
defimpl Edible, for: RPG.Poison do
  def eat(_poison, %RPG.Character{} = character) do
    updated_character = %RPG.Character{character | health: 0}
    {%RPG.EmptyBottle{}, updated_character}
  end
end

end

