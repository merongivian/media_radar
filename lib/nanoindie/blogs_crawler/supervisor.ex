defmodule Nanoindie.BlogsCrawler.Supervisor do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(blog) do
    spec = Supervisor.Spec.worker(Nanoindie.BlogsCrawler.Workers.Fetcher, [blog])
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 5)
  end
end
