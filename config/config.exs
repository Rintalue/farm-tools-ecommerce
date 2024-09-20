# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :project2,
  ecto_repos: [Project2.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :project2, Project2Web.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: Project2Web.ErrorHTML, json: Project2Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: Project2.PubSub,
  live_view: [signing_salt: "1aegUysx"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :project2, Project2.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  project2: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  project2: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :stripity_stripe,
  api_key:
    System.get_env(
      "sk_test_51Pq9URRuHbT5mBnoglmp644ioyzgY6JMRfPC871SCK107bKPmQmlhTfHSaTBCKHa7Oi4P4pmaD5rhXJO1hpHbA7J00bgacyzmq"
    )

# config :project2, Project2.Payments,
# paypal_client_id:
#   "AV7svX9iRpOj36DQmR66iy-URwXbeDzVbHSSN21VqdiYx0ty6KShXzyp-kkkb09sSaBRaL_LlWIJMzfe",
# paypal_secret:
# "EE8l1z-9RXF5xy2FS5PXTFl2gYAm7YduY8RZH6co_aQp9j_PjE9px7sN4i1JaOuQICH4CG3T5xWHeslO",
#
# paypal_mode: "sandbox"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
