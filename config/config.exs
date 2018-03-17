# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :jam_radar,
  ecto_repos: [JamRadar.Repo]

# Configures the endpoint
config :jam_radar, JamRadarWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "x5prAjcG68dORz1FooAyDXcHmbbJbHZR1BJ12dhiloHOfD2dNgo2L678fNJfah4r",
  render_errors: [view: JamRadarWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: JamRadar.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :jam_radar, JamRadar.BlogsCrawler.Scheduler,
  jobs: [
    {"*/60 * * * *",   fn -> JamRadar.BlogsCrawler.crawl() end}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
