alias Nanoindie.{Repo, Blog, Song}
require Ecto.Query

blog_songs_fetcher = fn(blog) ->
  if is_nil(blog.article_link_css) || String.trim(blog.article_link_css) == "" do
    if (rss_result = BlogFeedLinks.from_rss(blog.feed_url)) == [] do
      BlogFeedLinks.from_rss_crawling(blog.feed_url)
    else
      rss_result
    end
  else
    BlogFeedLinks.from_crawling(blog.feed_url, article_link_css: blog.article_link_css)
  end
end

blog_tasks = Enum.map Repo.all(Blog), fn(blog) ->
  Task.Supervisor.start_child Nanoindie.TaskSupervisor, fn ->
    links = blog_songs_fetcher.(blog)
    youtube_links = YoutubeLinksFilter.filter(links)

    Enum.each youtube_links, fn(yt_link) ->
      already_saved_song = Song
                 |> Ecto.Query.where(media_url: ^yt_link)
                 |> Repo.one()

      song_params = %{
        title: "Unknown",
        media_url: yt_link,
        source: "youtube",
        published_at: DateTime.utc_now
      }

      song = already_saved_song || Song.changeset(%Song{}, song_params) |> Repo.insert!
      Song.link_blog(song, blog)
    end
  end
end
