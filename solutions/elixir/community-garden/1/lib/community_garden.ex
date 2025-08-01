defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  def start(opts \\ []) do
    initial_state = %{next_plot_id: 1, plots: %{}}
    Agent.start(fn -> initial_state end, opts)
  end

  def list_registrations(pid) do
    Agent.get(pid, fn state -> Map.values(state.plots) end)
  end

  def register(pid, registered_to) do
    Agent.get_and_update(pid, fn state ->
      plot_id = state.next_plot_id
      plot = %Plot{plot_id: plot_id, registered_to: registered_to}

      new_plots = Map.put(state.plots, plot_id, plot)
      new_state = %{state | next_plot_id: plot_id + 1, plots: new_plots}

      {plot, new_state}
    end)
  end

  def release(pid, plot_id) do
    Agent.update(pid, fn state ->
      new_plots = Map.delete(state.plots, plot_id)
      %{state | plots: new_plots}
    end)
    :ok
  end

  def get_registration(pid, plot_id) do
    Agent.get(pid, fn state ->
      case Map.get(state.plots, plot_id) do
        nil -> {:not_found, "plot is unregistered"}
        plot -> plot
      end
    end)
  end
end
