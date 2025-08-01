defmodule LogLevel do
  def to_label(code, legacy?) do
    case {code, legacy?} do
      {0, false} -> :trace
      {0, true} -> :unknown
      {1, _} -> :debug
      {2, _} -> :info
      {3, _} -> :warning
      {4, _} -> :error
      {5, false} -> :fatal
      {5, true} -> :unknown
      _ -> :unknown
    end
  end

  def alert_recipient(code, legacy?) do
    case to_label(code, legacy?) do
      :error -> :ops
      :fatal -> :ops
      :unknown when legacy? -> :dev1
      :unknown -> :dev2
      _ -> false
    end
  end
end



