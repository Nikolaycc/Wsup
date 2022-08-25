import Config

config :wsup, ecto_repos: [Wsup.Repo]

config :wsup, Wsup.Repo,
  database: "Wsup",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"
