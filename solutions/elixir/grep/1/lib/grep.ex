defmodule Grep.File do
  @enforce_keys [:path]
  defstruct [:path, lines: [], found?: false]

  @type t :: %__MODULE__{path: String.t(), lines: [Grep.Line], found?: boolean()}

  @spec new(String.t()) :: t
  def new(path), do: %__MODULE__{path: path}

  @spec parse(t) :: t
  def parse(file) do
    file.path
    |> File.stream!()
    |> Stream.with_index()
    |> Stream.map(fn {text, index} -> Grep.Line.new(index + 1, text) end)
    |> then(&struct(file, lines: &1))
  end

  @spec may_mark_as_found(t, fun()) :: t
  def may_mark_as_found(file, match_fun) do
    file.lines
    |> Enum.any?(&match_fun.(&1.text))
    |> then(&struct(file, found?: &1))
  end

  @spec add_found_lines(t, fun()) :: t
  def add_found_lines(file, match_fun) do
    file.lines
    |> Enum.filter(&match_fun.(&1.text))
    |> then(&struct(file, lines: &1, found?: not Enum.empty?(&1)))
  end
end





defmodule Grep do
  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, paths) do
    options = Grep.Options.new(flags, paths)
    match_fun = match_fun(pattern, options)

    paths
    |> Stream.map(&grep_file(file(&1), match_fun, options))
    |> Stream.filter(& &1.found?)
    |> Enum.map_join("", &format_results(&1, options))
  end

  defp match_fun(pattern, options) do
    regex = Grep.Regex.compile(pattern, options)
    invert? = options.match_invert?

    fn text ->
      match? = String.match?(text, regex)
      (match? and not invert?) or (not match? and invert?)
    end
  end

  defp file(path), do: path |> Grep.File.new() |> Grep.File.parse()

  defp grep_file(file, match_fun, %{only_filepath?: true}),
    do: Grep.File.may_mark_as_found(file, match_fun)

  defp grep_file(file, match_fun, _), do: Grep.File.add_found_lines(file, match_fun)

  defp format_results(file, %{only_filepath?: true}), do: "#{file.path}\n"

  defp format_results(file, options),
    do: Enum.map(file.lines, &format_line(&1, file.path, options))

  defp format_line(line, path, options) do
    line.text
    |> may_append_number(line.number, options)
    |> may_append_path(path, options)
  end

  defp may_append_number(result, number, %{with_line_number?: true}), do: "#{number}:#{result}"
  defp may_append_number(result, _, _), do: result

  defp may_append_path(result, path, %{with_filepath?: true}), do: "#{path}:#{result}"
  defp may_append_path(result, _, _), do: result
end





defmodule Grep.Line do
  @enforce_keys [:number, :text]
  defstruct [:number, :text]

  @type t :: %__MODULE__{number: pos_integer(), text: String.t()}

  @spec new(number(), String.t()) :: %Grep.Line{}
  def new(number, text), do: %__MODULE__{number: number, text: text}
end





defmodule Grep.Options do
  defstruct with_line_number?: false,
            with_filepath?: false,
            only_filepath?: false,
            match_case_insensitive?: false,
            match_invert?: false,
            match_line?: false

  @type t :: %__MODULE__{
          with_line_number?: boolean(),
          with_filepath?: boolean(),
          only_filepath?: boolean(),
          match_case_insensitive?: boolean(),
          match_invert?: boolean(),
          match_line?: boolean()
        }

  @spec new([String.t()], [String.t()]) :: t
  def new(flags, paths), do: new() |> filepaths_to_options(paths) |> flags_to_options(flags)

  defp new(), do: %__MODULE__{}

  defp filepaths_to_options(opts, paths), do: %{opts | with_filepath?: length(paths) > 1}

  defp flags_to_options(opts, flags) do
    Enum.reduce(flags, opts, fn
      "-n", acc -> %{acc | with_line_number?: true}
      "-l", acc -> %{acc | only_filepath?: true}
      "-i", acc -> %{acc | match_case_insensitive?: true}
      "-v", acc -> %{acc | match_invert?: true}
      "-x", acc -> %{acc | match_line?: true}
      _, acc -> acc
    end)
  end
end





defmodule Grep.Regex do
  @flags %{caseless: "i"}

  @spec compile(String.t(), %Grep.Options{}) :: Regex.t()
  def compile(pattern, options),
    do: Regex.compile!(may_match_line(pattern, options), to_flags(options))

  defp may_match_line(pattern, %{match_line?: true}), do: "^#{pattern}$"
  defp may_match_line(pattern, _), do: pattern

  defp to_flags(%Grep.Options{} = options), do: may_add_flag_caseless("", options)

  defp may_add_flag_caseless(flags, options),
    do: may_add_flag(flags, @flags[:caseless], options.match_case_insensitive?)

  defp may_add_flag(flags, flag, true), do: flag <> flags
  defp may_add_flag(flags, _, _), do: flags
end
