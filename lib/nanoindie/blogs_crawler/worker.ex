defmodule Nanoindie.BlogsCrawler.Worker do
  alias Nanoindie.{Repo, Song}
  require Ecto.Query

  use GenServer, restart: :transient

  def start_link(blog) do
    GenServer.start_link(__MODULE__, [], name: String.to_atom(blog.name))
  end

  def fetch_songs(blog) do
    GenServer.cast(String.to_atom(blog.name), {:fetch_songs, blog})
  end

  def handle_cast({:fetch_songs, blog}, _links) do
    songs = blog
            |> crawl_songs()
            |> YoutubeLinksFilter.filter()
            |> persist_songs(blog)

    {:noreply, songs}
  end

  defp persist_songs(song_links, blog) do
    Enum.map song_links, fn(yt_link) ->
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

      song_params
    end
  end

  defp crawl_songs(blog) do
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
end
