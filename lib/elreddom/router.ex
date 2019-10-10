defmodule Router do
  use Plug.Router
  require Logger

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug(:match)
  plug(:dispatch)

  # Submit links
  post "/visited_links" do
    {status, body} = case conn.body_params do
      %{"links" => links} when is_list(links) ->
        now = Utils.timestamp()

        domains = for link <- links do
          {:ok, d} = Utils.domain(link)
          d
        end

        case Utils.Redis.write_domains(now, Enum.uniq(domains)) do
          result when is_list(result) -> {200, Jason.encode!(%{status: "ok"})}
          _ -> {500, Jason.encode!(%{status: "write_failed"})}
        end

        _ ->
          {400, Jason.encode!(%{status: "malformed_request"})}
    end

    send_resp(conn, status, body)
  end

  # Get unique domains
  get "/visited_domains" do
    {status, body} = case conn.query_params do
      %{"from" => from, "to" => to} ->
        case Utils.Redis.get_domains(from, to) do
          domains when is_list(domains) -> {200, Jason.encode!(%{status: "ok", domains: domains})}
          _ -> {500, Jason.encode!(%{status: "read_failed"})}
        end

        _ ->
          {400, Jason.encode!(%{status: "malformed_request"})}
      end
    send_resp(conn, status, body)
  end

  # Catch-up
  match _ do
    send_resp(conn, 404, "Not found")
  end
end

