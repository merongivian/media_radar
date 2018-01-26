ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Nanoindie.Repo, :manual)
Application.ensure_all_started(:bypass)
