defmodule Transmission do
  @doc """
  Return the transmission sequence for a message.
  """
  @spec get_transmit_sequence(binary()) :: binary()
  def get_transmit_sequence(message) do
    message
    |> Stream.unfold(chunk_func(7))
    |> Enum.reduce(<<>>, fn elem, acc ->
      <<acc::bitstring, elem::bitstring, 0::size(7 - bit_size(elem)), get_parity(elem)::1>>
    end)
  end

  @doc """
  Return the message decoded from the received transmission.
  """
  @spec decode_message(binary()) :: {:ok, binary()} | {:error, String.t()}
  def decode_message(<<>>), do: {:ok, <<>>}

  def decode_message(received_data) do
    reduced =
      received_data
      |> Stream.unfold(chunk_func(8))
      |> Enum.reduce_while(<<>>, &decode_acc/2)

    if is_bitstring(reduced) do
      reduced_bit_count = bit_size(reduced)
      size_in_bytes = div(reduced_bit_count, 8)
      <<result::binary-size(size_in_bytes), _::bitstring>> = reduced
      {:ok, <<result::binary-size(size_in_bytes)>>}
    else
      reduced
    end
  end

  defp chunk_func(bits_size) do
    fn
      <<>> ->
        nil

      <<next_data::size(bits_size), remaining::bitstring>> ->
        {<<next_data::size(bits_size)>>, remaining}

      last ->
        {last, <<>>}
    end
  end

  defp decode_acc(<<data::7, parity::1>>, acc) do
    case get_parity(<<data::7>>) do
      ^parity -> {:cont, <<acc::bitstring, data::7>>}
      _ -> {:halt, {:error, "wrong parity"}}
    end
  end

  defp get_parity(data) do
    bit_count = bit_size(data)

    0..(bit_count - 1)
    |> Enum.map(fn i ->
      <<_::size(i), value::1, _::bitstring>> = data
      value
    end)
    |> Enum.reduce(0, &Bitwise.bxor/2)
  end
end