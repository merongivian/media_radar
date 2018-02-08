alias Nanoindie.{Repo, Blog, Song}

Enum.map Repo.all(Blog), fn(blog) ->
  Nanoindie.BlogsCrawler.Supervisor.start_child(blog)
  Nanoindie.BlogsCrawler.Worker.fetch_songs(blog)
end
