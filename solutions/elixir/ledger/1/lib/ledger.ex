defmodule Ledger do
  @moduledoc """
  Refactoring steps:

  1. Extract table header into `table_header/1` that takes into account `locale`.
  2. Avoid if/else in the `format_entries/3`, use pipeline.
  3. Extract `ledger_sorter/2` from the `format_entries/3`; use shorter syntax for `Enum.map/2` in the same function.
  4. Use `then/2` in the `format_entries/3` to make pipeline straightforward.
  5. Extract `format_date/2` (initial attempt).
  6. Extract `format_number/2` (initial attempt): two clauses (for locales).
  7. Extract `format_amount/3` (initial attempt).
  8. Extract `format_description/1` (initial attempt).
  9. Define `cell/2` and `row/1` helpers. Plus `@date_width`, `@desc_width`, and `@amnt_width`. Use them in `table_header/1`.
  10. Remove `format_description/1` as it is redundant now. Use `@amnt_width` in `format_amount/4`.
  11. Introduce `format_decimal/1` and `format_whole/2` and clean up the mess in the `format_number/2` function clauses.
  12. Introduce `@currencies` map, use it in the `format_amount/4`.
  13. Rewrite `format_amount/4` using `if` and `cond`.

  After review of the 1st iteration:

  14. Remove redundant `List.flatten/1` from the `format_entries/3`, and replace `[header, rows]` with `[header | rows]`.
  15. Replace `ledger_sorter/2` and `Enum.sort/2` with `Enum.sort_by([...], &{&1.date.day, &1.description, &1.amount_in_cents})` in `format_entries/3`.
  16. Introduce `table_row/3` helper and use it instead of the raw `row/1` in the `table_header/1` and `format_entry/3` functions (to mitigate risk of incosistencies in the columns' widths).
  17. Move `entry` argument to the first place in the `format_entry/3` to make it a bit more consistent with the rest of functions (which receive formatting options – e.g., currency or local – as last arguments).
  18. Pass `cents < 3` into `format_amount/4` invocation and name the corresponding argument directly as `negative?` to use it inside the function's decision's logic. 
  19. Introduce mini-helper `pre_pad/3` to replace `... |> to_string() |> String.pad_leading(...)` repeatative constructions.
  20. A few more minimum touches: rename `currencies` variable to `symbol` and similar things here and there around the module source code.

  P.S. Also moved refactoring steps notes to the module documentation block, to have them next to the source code.
  """

  @date_width 10
  @desc_width 25
  @amnt_width 13
  @currencies %{
    usd: "$",
    eur: "€"
  }

  @type currency :: :usd | :eur
  @type locale :: :en_US | :nl_NL
  @type entry :: %{amount_in_cents: integer(), date: Date.t(), description: String.t()}

  @doc """
  Format the given entries given a currency and locale
  """
  @spec format_entries(currency(), locale(), list(entry())) :: String.t()
  def format_entries(currency, locale, entries) do
    entries
    |> Enum.sort_by(&{&1.date.day, &1.description, &1.amount_in_cents})
    |> Enum.map(&format_entry(&1, currency, locale))
    |> then(fn rows ->
      header = table_header(locale)

      [header | rows]
      |> Enum.join("\n")
      |> Kernel.<>("\n")
    end)
  end

  ### Localized Headers

  defp table_header(:en_US), do: table_row("Date", "Description", "Change")
  defp table_header(:nl_NL), do: table_row("Datum", "Omschrijving", "Verandering")

  ### Data Formatting Helpers

  # Prepares data for the row of date, description, and amount
  defp format_entry(%{amount_in_cents: cents, date: date, description: desc}, currency, locale) do
    date = format_date(date, locale)

    amount =
      cents
      |> format_number(locale)
      |> format_amount(cents < 0, currency, locale)

    table_row(date, desc, amount)
  end

  # Takes the date struct and locale, and formats it using the weird US date order, or a normal one
  defp format_date(date, locale) do
    day = pre_pad(date.day, 2, "0")
    month = pre_pad(date.month, 2, "0")
    year = to_string(date.year)

    if locale == :en_US do
      "#{month}/#{day}/#{year}"
    else
      "#{day}-#{month}-#{year}"
    end
  end

  # Takes amount in cents and locale, and formats it to human-readable format, e.g.: 1,234.56
  # Group and decimal separators depend on the local
  defp format_number(amount_in_cents, locale) do
    decimal_separator = if locale == :en_US, do: ".", else: ","
    group_separator = if locale == :en_US, do: ",", else: "."
    amount_in_cents = abs(amount_in_cents)

    whole = div(amount_in_cents, 100)
    cents = rem(amount_in_cents, 100)

    Enum.join([
      format_whole(whole, group_separator),
      decimal_separator,
      format_decimal(cents)
    ])
  end

  # Prepend with 0 if needed
  defp format_decimal(cents), do: pre_pad(cents, 2, "0")

  # A bit of trickery here is a triple reversing of the full list of digits and then inside a group
  # separately: this allows us to to add separators from right to left for each "thousand", despite
  # the length of the amount
  defp format_whole(cents, group_separator) do
    cents
    |> Integer.digits()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.map(fn group ->
      group
      |> Enum.reverse()
      |> Enum.join()
    end)
    |> Enum.reverse()
    |> Enum.join(group_separator)
  end

  # Takes into consideration a currency and locale. US (as it happens) uses their own format for
  # displaying negative numbers (by wrapping them in parentheses), so we have quite a logic here.
  defp format_amount(number, negative?, currency, locale) do
    symbol = @currencies[currency]
    separator = if locale == :en_US, do: "", else: " "

    formatted =
      cond do
        negative? and locale == :en_US -> "(#{symbol}#{number})"
        negative? -> "#{symbol} -#{number} "
        true -> "#{symbol}#{separator}#{number} "
      end

    # re-using @amnt_width here to align amount to the right in the column
    pre_pad(formatted, @amnt_width, " ")
  end

  ### Basic Formatting and Table Helpers

  defp pre_pad(input, count, padding),
    do: input |> to_string() |> String.pad_leading(count, padding)

  defp table_row(date, desc, amount) do
    row([
      cell(date, @date_width),
      cell(desc, @desc_width),
      cell(amount, @amnt_width)
    ])
  end

  defp row(cells), do: Enum.join(cells, " | ")

  defp cell(contents, width) do
    if String.length(contents) > width do
      String.slice(contents, 0, width - 3) <> "..."
    else
      String.pad_trailing(contents, width, " ")
    end
  end
end
