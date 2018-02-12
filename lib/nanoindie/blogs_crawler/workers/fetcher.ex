defmodule Nanoindie.BlogsCrawler.Workers.Fetcher do
  alias Nanoindie.{Song, Repo}
  import YoutubeLinksFilter, only: [filter: 1]
  require Ecto.Query

  use Agent

  def run(blog) do
    Task.start_link fn ->
      start_link(blog)
      fetch_songs(blog)
    end
  end

  def start_link(blog) do
    Agent.start_link(fn -> [] end, name: String.to_atom(blog.feed_url))
  end

  def songs(blog) do
    Agent.get(String.to_atom(blog.feed_url), & &1)
  end

  def fetch_songs(blog) do
    songs = blog
            |> song_links()
            |> reject_persisted_songs(blog)
            |> Enum.map(&create_song/1)

    Agent.update(String.to_atom(blog.feed_url), & songs ++ &1)
  end

  def reject_persisted_songs(song_links, blog) do
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
    %Song{
      title: "Unknown",
      media_url: link,
      source: "youtube",
      published_at: DateTime.utc_now
    }
  end
end
