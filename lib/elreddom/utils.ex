defmodule Utils do
  def timestamp do
    :os.system_time(:seconds)
  end

  def domain(link) do
    case URI.parse(link) do
      %URI{authority: domain} when is_binary(domain) -> {:ok, domain}
      _ ->
        case URI.parse("http://" <> link) do
          %URI{authority: domain} when is_binary(domain) -> {:ok, domain}
          _ -> nil
        end
    end
  end
end
