alias Nanoindie.{Repo, Blog}

Enum.map Repo.all(Blog), fn(blog) ->
  Task.start_link fn ->
    Nanoindie.BlogsCrawler.Supervisor.start_child(blog)
    Nanoindie.BlogsCrawler.Workers.Fetcher.fetch_songs(blog)
  end
end
