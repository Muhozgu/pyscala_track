defmodule RemoteControlCar do
  @enforce_keys [:nickname]
  defstruct [
    :nickname,  # required, no default
    battery_percentage: 100,
    distance_driven_in_meters: 0
  ]

  # Initializes with default nickname "none"
  def new() do
    %RemoteControlCar{nickname: "none"}
  end

  # Initializes with given nickname
  def new(nickname) do
    %RemoteControlCar{nickname: nickname}
  end

  # Returns the distance string
  def display_distance(%RemoteControlCar{distance_driven_in_meters: dist}) do
    "#{dist} meters"
  end

  # Returns battery status string
  def display_battery(%RemoteControlCar{battery_percentage: 0}) do
    "Battery empty"
  end

  def display_battery(%RemoteControlCar{battery_percentage: pct}) do
    "Battery at #{pct}%"
  end

  # Drives car if battery > 0
  def drive(%RemoteControlCar{battery_percentage: 0} = car) do
    car
  end

  def drive(%RemoteControlCar{battery_percentage: battery, distance_driven_in_meters: dist} = car) do
    %RemoteControlCar{
      car
      | battery_percentage: battery - 1,
        distance_driven_in_meters: dist + 20
    }
  end
end


