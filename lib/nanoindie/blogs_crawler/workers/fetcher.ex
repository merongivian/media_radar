defmodule Nanoindie.BlogsCrawler.Workers.Fetcher do
  alias Nanoindie.Repo
  import YoutubeLinksFilter, only: [filter: 1]
  require Ecto.Query

  use GenServer

  def start_link(blog) do
    GenServer.start_link(__MODULE__, [], name: String.to_atom(blog.name))
  end

  def get_songs(blog) do
    GenServer.call(String.to_atom(blog.name), {:get_songs, blog})
  end

  def fetch_songs(blog) do
    GenServer.cast(String.to_atom(blog.name), {:fetch_songs, blog})
  end

  def handle_cast({:fetch_songs, blog}, _songs) do
    songs = blog
            |> song_links()
            |> reject_persisted_songs(blog)
            |> Enum.map(&create_song/1)

    {:noreply, songs}
  end

  def handle_call({:get_songs, blog}, _from, songs) do
    {:reply, songs, songs}
  end

  defp reject_persisted_songs(song_links, blog) do
    Enum.filter song_links, fn(song_link) ->
      blog
      |> Ecto.assoc(:songs)
      |> Ecto.Query.where(media_url: ^song_link)
      |> Repo.one()
      |> is_nil()
    end
  end

  defp song_links(blog) do
    if is_nil(blog.article_link_css) || String.trim(blog.article_link_css) == "" do
     rss_song_links(blog)
    else
      blog.feed_url
      |> BlogFeedLinks.from_crawling(article_link_css: blog.article_link_css)
      |> filter()
    end
  end

  defp rss_song_links(blog) do
    pure_rss_song_links = blog.feed_url
                          |> BlogFeedLinks.from_rss()
                          |> filter()

    if pure_rss_song_links == [] do
      blog.feed_url
      |> BlogFeedLinks.from_rss_crawling()
      |> filter()
    else
      pure_rss_song_links
    end
  end

  defp create_song(link) do
    %{
      title: "Unknown",
      media_url: link,
      source: "youtube",
      published_at: DateTime.utc_now
    }
  end
end
