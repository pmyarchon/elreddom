defmodule Elreddom do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.debug("Elreddom started...", [])
    web_port = Application.get_env(:elreddom, :web_port)

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Router, [], port: web_port),
      {Redix, name: :redix}
    ]

    Supervisor.start_link(children, [strategy: :one_for_one, name: Elreddom.Supervisor])
  end
end
