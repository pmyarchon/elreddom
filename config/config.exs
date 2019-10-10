use Mix.Config

config :elreddom,
  web_port: 7002

config :redix,
  host: "localhost",
  port: 6379,
  database: "elreddom_test"
