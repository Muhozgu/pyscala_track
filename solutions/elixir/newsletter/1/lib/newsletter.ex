defmodule Newsletter do
  def read_emails(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  # Open log with :write to clear file contents on each run
  def open_log(path) do
    {:ok, pid} = File.open(path, [:write, :utf8])
    pid
  end

  def log_sent_email(pid, email) do
    IO.write(pid, email <> "\n")
  end

  def close_log(pid) do
    File.close(pid)
  end

  def send_newsletter(emails_path, log_path, send_fun) do
    emails = read_emails(emails_path)
    log_pid = open_log(log_path)

    Enum.each(emails, fn email ->
      case send_fun.(email) do
        :ok -> log_sent_email(log_pid, email)
        :error -> :skip
      end
    end)

    close_log(log_pid)
  end
end



