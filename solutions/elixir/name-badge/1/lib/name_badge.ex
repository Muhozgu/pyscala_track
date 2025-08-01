defmodule NameBadge do
  def print(nil, name, department) do
    "#{name} - #{String.upcase(department || "OWNER")}"
  end

  def print(id, name, department) do
    "[#{id}] - #{name} - #{String.upcase(department || "OWNER")}"
  end
end

# Example Test
IO.puts(NameBadge.print(1, "Anna Johnson", nil))  # Expected output: "[1] - Anna Johnson - OWNER"
