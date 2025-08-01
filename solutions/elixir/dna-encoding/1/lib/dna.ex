defmodule DNA do
  # --- Encode a single nucleotide to 4-bit binary ---
  def encode_nucleotide(?\s), do: 0b0000
  def encode_nucleotide(?A),  do: 0b0001
  def encode_nucleotide(?C),  do: 0b0010
  def encode_nucleotide(?G),  do: 0b0100
  def encode_nucleotide(?T),  do: 0b1000

  # --- Decode a 4-bit binary to nucleotide ---
  def decode_nucleotide(0b0000), do: ?\s
  def decode_nucleotide(0b0001), do: ?A
  def decode_nucleotide(0b0010), do: ?C
  def decode_nucleotide(0b0100), do: ?G
  def decode_nucleotide(0b1000), do: ?T

  # --- Public: Encode a DNA binary or charlist into a bitstring ---
  def encode(dna) when is_binary(dna) do
    dna
    |> to_charlist()
    |> do_encode_charlist(<<>>)
  end

  def encode(dna) when is_list(dna) do
    do_encode_charlist(dna, <<>>)
  end

  # --- Tail-recursive helper for encoding a charlist ---
  defp do_encode_charlist([], acc), do: acc

  defp do_encode_charlist([head | tail], acc) do
    code = encode_nucleotide(head)
    do_encode_charlist(tail, <<acc::bitstring, code::size(4)>>)
  end

  # --- Public: Decode a bitstring back into a DNA charlist ---
  def decode(<<>>), do: []

  def decode(bitstring) do
    bitstring
    |> do_decode_bitstring([])
    |> Enum.reverse()
  end

  # --- Tail-recursive helper for decoding ---
  defp do_decode_bitstring(<<>>, acc), do: acc

  defp do_decode_bitstring(<<code::size(4), rest::bitstring>>, acc) do
    nucleotide = decode_nucleotide(code)
    do_decode_bitstring(rest, [nucleotide | acc])
  end
end