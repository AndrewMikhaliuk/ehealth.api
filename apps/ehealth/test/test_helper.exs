{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(EHealth.Repo, :manual)
# Ecto.Adapters.SQL.Sandbox.mode(EHealth.PRMRepo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(EHealth.EventManagerRepo, :manual)
