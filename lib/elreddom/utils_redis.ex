defmodule Utils.Redis do
  @ts_key "timestamp_keys"

  def add_timestamp_key(ts) do
    command(["ZADD", @ts_key, ts, ts])
  end

  def get_timestamp_keys(from, to) do
    command(["ZRANGEBYSCORE", @ts_key, from, to])
  end

  def write_domains(ts, domains) do
    pipeline([
      ["ZADD", @ts_key, ts, ts],
      ["SADD", to_string(ts) | domains]
    ])
  end

  def get_domains(from, to) do
    case get_timestamp_keys(from, to) do
      keys when is_list(keys) and keys !== [] -> command(["SUNION" | keys])
      _ -> nil
    end
  end

  # Internal functions
  defp command(cmd) do
    case Redix.command(:redix, cmd) do
      {:ok, result} -> result
      _ -> nil
    end
  end

  defp pipeline(cmds) do
    case Redix.pipeline(:redix, cmds) do
      {:ok, result} -> result
      _ -> nil
    end
  end
end
