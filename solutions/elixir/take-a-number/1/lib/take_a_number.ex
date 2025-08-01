defmodule TakeANumber do
  def start() do
    # Spawn a new process with an initial state of 0
    spawn(fn -> loop(0) end)
  end

  defp loop(state) do
    receive do
      {:report_state, sender_pid} ->
        # Send the current state back to the sender
        send(sender_pid, state)
        # Continue the loop with the same state
        loop(state)

      {:take_a_number, sender_pid} ->
        # Increment the state by 1
        new_state = state + 1
        # Send the new state back to the sender
        send(sender_pid, new_state)
        # Continue the loop with the new state
        loop(new_state)

      :stop ->
        # Stop the process
        :ok

      _other ->
        # Ignore any other messages
        loop(state)
    end
  end
end
