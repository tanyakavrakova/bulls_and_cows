use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bulls_and_cows, BullsAndCowsWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Comeonin password hashing test config
# config :argon2_elixir,
# t_cost: 2,
# m_cost: 8
config :bcrypt_elixir, log_rounds: 4
# config :pbkdf2_elixir, rounds: 1

# Configure your database
config :bulls_and_cows, BullsAndCows.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "tad",
  database: "bulls_and_cows_test",
  hostname: "localhost",
  pool_size: 10
