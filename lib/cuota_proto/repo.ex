defmodule CuotaProto.Repo do
  use Ecto.Repo,
    otp_app: :cuota_proto,
    adapter: Ecto.Adapters.Postgres
end
