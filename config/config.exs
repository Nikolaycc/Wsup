import Config

config :wsup, ecto_repos: [Wsup.Repo]

config :wsup, Wsup.Repo,
  database: "Wsup",
  username: "postgres",
  password: "Nikoniko2",
  hostname: "localhost",
  port: "5432"
