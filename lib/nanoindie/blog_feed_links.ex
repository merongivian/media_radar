defmodule BlogFeedLinks do
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
    |> fetch_page(with_agent: true)
    |> Floki.find(article_link_css)
    |> get_links()
    |> Enum.map(&(complete_internal_url feed_url, &1))
    |> Enum.flat_map(&page_links/1)
  end

  defp page_links(url) do
    url
    |> fetch_page(with_agent: true)
    |> get_links()
  end

  defp rss_entries(feed_url) do
    feed_url
    |> fetch_page()
    |> Rss.Parser.parse()
  end

  defp fetch_page(url, opts \\ [with_agent: false]) do
    user_agent = if opts[:with_agent] do
                   %{"User-Agent" => "firefox"}
                 else
                   []
                 end

    url
    |> Tesla.get(headers: user_agent)
    |> Map.get(:body)
  end

  defp get_links(content) do
    a_links = content
    |> Floki.find("a")
    |> Floki.attribute("href")

    # video links
    iframe_links = content
    |> Floki.find("iframe")
    |> Floki.attribute("src")

    a_links ++ iframe_links
  end

  defp complete_internal_url(feed_url, url) do
    if String.starts_with?(url, "/") do
      feed_url
      |> URI.merge(url)
      |> URI.to_string()
    else
      url
    end
  end
end
