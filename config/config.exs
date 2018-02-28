# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bulls_and_cows, ecto_repos: [BullsAndCows.Repo]

# Configures the endpoint
config :bulls_and_cows, BullsAndCowsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ebF1n0NUnX784NlpqXD5RfSDegHca3EJobv0hMUGLJtxjegkvO/BGJ+3i8yNW7Ea",
  render_errors: [view: BullsAndCowsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BullsAndCows.PubSub, adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  token_salt: "NFmTjReD",
  endpoint: BullsAndCowsWeb.Endpoint

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
