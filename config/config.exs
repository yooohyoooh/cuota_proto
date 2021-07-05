# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cuota_proto,
  ecto_repos: [CuotaProto.Repo]

# Configures the endpoint
config :cuota_proto, CuotaProtoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "juq5C85+D5dPiJ9vYH2qzfdee/5pVDJv4Dcpgb7QplAOV0JFbCpNHUrbjECa/ORM",
  render_errors: [view: CuotaProtoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CuotaProto.PubSub,
  live_view: [signing_salt: "e1U+r4Hp"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"



config :cuota_proto, CuotaProto.Util.Mailer,
adapter: Bamboo.SendGridAdapter,
api_key: "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",
  # or {:system, “SENDGRID_API_KEY”},
  # or {ModuleName, :method_name, []}
hackney_opts: [
  recv_timeout: :timer.minutes(1)
]
