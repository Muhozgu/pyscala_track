defmodule FileSniffer do
  @types %{
    "exe" => {"application/octet-stream", <<0x7F, 0x45, 0x4C, 0x46>>},
    "bmp" => {"image/bmp", <<0x42, 0x4D>>},
    "png" => {"image/png", <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>},
    "jpg" => {"image/jpg", <<0xFF, 0xD8, 0xFF>>},
    "gif" => {"image/gif", <<0x47, 0x49, 0x46>>}
  }

  def type_from_extension(extension) do
    Map.get(@types, extension, {nil, nil})
    |> elem(0)
  end

  def type_from_binary(file_binary) when is_binary(file_binary) do
    Enum.find_value(@types, fn {_ext, {mime, signature}} ->
      if binary_starts_with?(file_binary, signature), do: mime, else: nil
    end)
  end

  def type_from_binary(_), do: nil

  def verify(file_binary, extension) do
    declared_type = type_from_extension(extension)
    actual_type = type_from_binary(file_binary)

    if declared_type != nil and declared_type == actual_type do
      {:ok, actual_type}
    else
      {:error, "Warning, file format and file extension do not match."}
    end
  end

  defp binary_starts_with?(bin, sig)
       when is_binary(bin) and is_binary(sig) and byte_size(bin) >= byte_size(sig) do
    :binary.part(bin, 0, byte_size(sig)) == sig
  end

  defp binary_starts_with?(_, _), do: false
end
