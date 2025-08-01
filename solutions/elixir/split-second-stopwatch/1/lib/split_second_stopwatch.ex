defmodule SplitSecondStopwatch do
  @doc """
  A stopwatch that can be used to track lap times.
  """

  @type state :: :ready | :running | :stopped

  defmodule Stopwatch do
    @type t :: :state | :current_lap | :previous_laps
    defstruct [state: :ready, current_lap: Time.new!(0,0,0), previous_laps: []]
  end

  @spec new() :: Stopwatch.t()
  def new(), do: %Stopwatch{}

  @spec state(Stopwatch.t()) :: state()
  def state(stopwatch), do: stopwatch.state

  @spec current_lap(Stopwatch.t()) :: Time.t()
  def current_lap(stopwatch), do: stopwatch.current_lap

  @spec previous_laps(Stopwatch.t()) :: [Time.t()]
  def previous_laps(stopwatch), do: stopwatch.previous_laps |> Enum.reverse()

  @spec advance_time(Stopwatch.t(), Time.t()) :: Stopwatch.t()
  def advance_time(stopwatch, time) do
    if stopwatch.state == :running do
      {seconds, _} = Time.to_seconds_after_midnight(time)
      new_time = Time.add(stopwatch.current_lap, seconds)
      %{stopwatch | current_lap: new_time}
    else
      stopwatch
    end
  end

  @spec total(Stopwatch.t()) :: Time.t()
  def total(stopwatch) do
    previous_laps = if stopwatch.previous_laps == [] do
      Time.new!(0,0,0)
    else
      Enum.reduce(stopwatch.previous_laps, fn x, acc ->
      {seconds, _microseconds} = Time.to_seconds_after_midnight(x)
      Time.add(acc, seconds)
    end)
    end
    {previous_laps_seconds, _} = Time.to_seconds_after_midnight(previous_laps)
    Time.add(stopwatch.current_lap, previous_laps_seconds)
  end

  @spec start(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def start(stopwatch) do
    if stopwatch.state in [:ready, :stopped] do
      %{stopwatch | state: :running}
    else
      {:error, "cannot start an already running stopwatch"}
    end
  end

  @spec stop(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def stop(stopwatch) do
    if stopwatch.state in [:running] do
      %{stopwatch | state: :stopped}
    else
      {:error, "cannot stop a stopwatch that is not running"}
    end
  end

  @spec lap(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def lap(stopwatch) do
    if stopwatch.state == :running do
      stopwatch = %{stopwatch | previous_laps: [stopwatch.current_lap | stopwatch.previous_laps]}
      %{stopwatch | current_lap: Time.new!(0,0,0)}
    else
      {:error, "cannot lap a stopwatch that is not running"}
    end
  end

  @spec reset(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def reset(stopwatch) do
    if stopwatch.state == :stopped do
      %{stopwatch | current_lap: Time.new!(0,0,0), previous_laps: [], state: :ready}
    else
      {:error, "cannot reset a stopwatch that is not stopped"}
    end
  end
end