defmodule Nanoindie.BlogsCrawler.Fetcher do
  alias Nanoindie.Repo
  require Ecto.Query

  def fetch(blog) do
    blog
    |> song_links()
    |> reject_persisted_songs(blog)
    |> Enum.map(&create_song/1)
  end

  defp reject_persisted_songs(song_links, blog) do
    Enum.filter song_links, fn(song_link) ->
      blog
      |> Ecto.assoc(:songs)
      |> Ecto.Query.where(media_url: ^song_link.url)
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
      media_url: link.url,
      source: "youtube",
      published_at: link.published_at
    }
  end

  defp filter(links) do
    filtered_urls = links
                    |> Enum.map(& Map.get(&1, :url))
                    |> Youtube.UrlsFilter.filter()

    Enum.filter links, fn(link) ->
      Enum.find(filtered_urls, &(link.url == &1))
    end
  end
end
