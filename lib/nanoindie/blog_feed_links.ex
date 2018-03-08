defmodule BlogFeedLinks do
  use Tesla

  #plug Tesla.Middleware.TupleForEconnrefused

  defmodule Link do
    defstruct url: "", published_at: DateTime.utc_now
  end

  def from_rss(feed_url) do
    feed_url
    |> rss_entries()
    |> Enum.flat_map(& create_links(&1, urls_from: :content))
  end

  def from_rss_crawling(feed_url) do
    feed_url
    |> rss_entries()
    |> Enum.flat_map(& create_links(&1, urls_from: :url))
  end

  def from_crawling(feed_url, article_link_css: article_link_css) do
    feed_url
    |> fetch_page(with_agent: true)
    |> Floki.find(article_link_css)
    |> crawl_urls()
    |> Enum.map(&(complete_internal_url feed_url, &1))
    |> Enum.flat_map(&page_urls/1)
    |> Enum.map(&create_link(url: &1))
  end

  defp create_links(entry, urls_from: :content = urls_from) do
    entry
    |> Map.get(urls_from)
    |> crawl_urls()
    |> Enum.map(fn crawled_url ->
      create_link(url: crawled_url, published_at: entry.published)
    end)
  end

  defp create_links(entry, urls_from: :url = urls_from) do
    entry
    |> Map.get(urls_from)
    |> page_urls()
    |> Enum.map(fn crawled_url ->
      create_link(url: crawled_url, published_at: entry.published)
    end)
  end

  defp create_link(url: url) do
    %BlogFeedLinks.Link{url: url}
  end

  defp create_link(url: url, published_at: published_at) do
    %BlogFeedLinks.Link{url: url, published_at: published_at}
  end

  defp page_urls(page_link) do
    page_link
    |> fetch_page(with_agent: true)
    |> crawl_urls()
  end

  defp rss_entries(feed_url) do
    feed_url
    |> fetch_page()
    |> Feedraptor.parse()
    |> Map.get(:entries)
  end

  defp fetch_page(url, opts \\ [with_agent: false]) do
    user_agent = if opts[:with_agent] do
                   %{"User-Agent" => "firefox"}
                 else
                   []
                 end

    #case get(url, headers: user_agent) do
      #{:ok, response} -> response.body
      #{:error, :econnrefused} -> ""
    #end

    url
    |> get(headers: user_agent)
    |> Map.get(:body)
  end

  defp crawl_urls(content) do
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
