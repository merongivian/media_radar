defmodule Nanoindie.BlogsCrawler.Fetcher do
  alias Nanoindie.Repo
  import Youtube.LinksFilter, only: [filter: 1]
  require Ecto.Query

  def fetch(blog) do
    res = blog
    |> song_links()
    |> reject_persisted_songs(blog)
    |> Enum.map(&create_song/1)
    res
  end

  def reject_persisted_songs(song_links, blog) do
    Enum.filter song_links, fn(song_link) ->
      blog
      |> Ecto.assoc(:songs)
      |> Ecto.Query.where(media_url: ^song_link.url)
      |> Repo.one()
      |> is_nil()
    end
  end

  def song_links(blog) do
    if is_nil(blog.article_link_css) || String.trim(blog.article_link_css) == "" do
      rss_song_links(blog)
    else
      blog.feed_url
      |> BlogFeedLinks.from_crawling(article_link_css: blog.article_link_css)
      |> filter()
    end
  end

  def rss_song_links(blog) do
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

  def create_song(link) do
    %{
      title: "Unknown",
      media_url: link.url,
      source: "youtube",
      published_at: link.published_at
    }
  end
end
