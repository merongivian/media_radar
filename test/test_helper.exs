ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Nanoindie.Repo, :manual)
Application.ensure_all_started(:bypass)
Application.ensure_all_started(:ex_machina)
