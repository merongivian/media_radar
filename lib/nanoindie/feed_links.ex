defmodule FeedLinks do
  def from_rss(feed_url) do
    feed_url
    |> rss_entries()
    |> Enum.flat_map(&(Map.get &1, :content))
    |> Enum.flat_map(&get_links/1)
  end

  def from_rss_crawling(feed_url) do
    feed_url
    |> rss_entries()
    |> Enum.flat_map(&(Map.get &1, :link))
    |> Enum.flat_map(&page_links/1)
  end

  def from_crawling(feed_url, article_link_css: article_link_css) do
    feed_url
    |> fetch_page()
    |> Floki.find(article_link_css)
    |> get_links()
    |> Enum.flat_map(&page_links/1)
  end

  defp page_links(url) do
    url
    |> fetch_page()
    |> get_links()
  end

  defp rss_entries(feed_url) do
    feed_url
    |> fetch_page()
    |> FeedParser.parse()
  end

  defp fetch_page(url) do
    url
    |> HTTPoison.get!()
    |> Map.get(:body)
  end

  defp get_links(content) do
    content
    |> Floki.find("a")
    |> Floki.attribute("href")
  end
end
