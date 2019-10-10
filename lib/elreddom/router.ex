defmodule Router do
  use Plug.Router
  require Logger

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug JSONHeaderPlug
  plug(:match)
  plug(:dispatch)

  # Submit links
  post "/visited_links" do
    {status, result} = case conn.body_params do
      %{"links" => links} when is_list(links) ->
        now = Utils.timestamp()

        domains = for link <- links do
          {:ok, d} = Utils.domain(link)
          String.downcase(d)
        end

        case Utils.Redis.write_domains(now, Enum.uniq(domains)) do
          result when is_list(result) -> {201, %{status: "ok"}}
          _ -> {500, %{status: "write_failed"}}
        end

      _ -> {400, %{status: "malformed_request"}}
    end

    send_resp(conn, status, Jason.encode!(result))
  end

  # Get unique domains
  get "/visited_domains" do
    {status, result} = case conn.query_params do
      %{"from" => from, "to" => to} ->
        case Utils.Redis.get_domains(from, to) do
          domains when is_list(domains) -> {200, %{status: "ok", domains: domains}}
          _ -> {500, %{status: "read_failed"}}
        end

      _ -> {400, %{status: "malformed_request"}}
    end

    send_resp(conn, status, Jason.encode!(result))
  end

  # Catch-up
  match _ do
    send_resp(conn, 404, Jason.encode!(%{status: "not_found"}))
  end
end
