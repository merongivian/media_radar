alias Nanoindie.{Repo, Blog}
alias Nanoindie.BlogsCrawler.Workers.{Fetcher, Persister}

Enum.map Repo.all(Blog), fn(blog) ->
  Task.start_link fn ->
    Nanoindie.BlogsCrawler.Supervisor.start_child(blog)
    Fetcher.fetch_songs(blog)
    Persister.persist(blog)
  end
end
