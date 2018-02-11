defmodule BlogsCrawler.Workers.FetcherTest do
  use Nanoindie.DataCase
  use ExUnit.Case, async: true

  alias Nanoindie.BlogsCrawler.Workers.Fetcher

  import Nanoindie.Factory

  setup context do
    bypass = Bypass.open(port: 1234)
    feed_url = "http://localhost:#{bypass.port}"

    response = File.read! "test/nanoindie/fixtures/songs_fetching/#{context[:fixture]}"

    Bypass.expect bypass, "GET", "/", &(Plug.Conn.resp(&1, 200, response))

    {:ok, feed_url: feed_url, bypass: bypass}
  end

  @tag fixture: "blog_rss/with_youtube_links.xml"
  test "fetch_songs/1 from rss", %{feed_url: feed_url} do
    blog = insert(:blog, feed_url: feed_url)

    Fetcher.start_link(blog)
    Fetcher.fetch_songs(blog)
    fetched_links = blog
                    |> Fetcher.songs()
                    |> Enum.map(& &1.media_url)
                    |> Enum.sort()

    links = ~w(
      https://www.youtube.com/watch?v=1
      https://www.youtube.com/watch?v=2
      https://www.youtube.com/watch?v=3
      https://www.youtube.com/watch?v=4
      https://www.youtube.com/watch?v=5
      https://www.youtube.com/watch?v=6
    )

    assert fetched_links == links
  end

  @tag fixture: "blog_rss/without_youtube_links.xml"
  test "fetch_songs/1 from crawled rss links", %{feed_url: feed_url, bypass: bypass} do
    Enum.each ~w(/one /two /three), fn (entry_path) ->
      entry_page = File.read! "test/nanoindie/fixtures/songs_fetching/blog_pages/#{entry_path}.html"
      Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
    end

    blog = insert(:blog, feed_url: feed_url)

    Fetcher.start_link(blog)
    Fetcher.fetch_songs(blog)
    fetched_links = blog
                    |> Fetcher.songs()
                    |> Enum.map(& &1.media_url)
                    |> Enum.sort()

    links = ~w(
      https://www.youtube.com/watch?v=1
      https://www.youtube.com/watch?v=2
      https://www.youtube.com/watch?v=3
      https://www.youtube.com/watch?v=4
      https://www.youtube.com/watch?v=5
      https://www.youtube.com/watch?v=6
    )

    assert fetched_links == links
  end

  @tag fixture: "blog_with_articles.html"
  test "fetch_songs/1 from crawled article links", %{feed_url: feed_url, bypass: bypass} do
    Enum.each ~w(/one /two /three), fn (entry_path) ->
      entry_page = File.read! "test/nanoindie/fixtures/songs_fetching/blog_pages/#{entry_path}.html"
      Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
    end

    blog = insert(:blog, feed_url: feed_url, article_link_css: ".song")

    Fetcher.start_link(blog)
    Fetcher.fetch_songs(blog)
    fetched_links = blog
                    |> Fetcher.songs()
                    |> Enum.map(& &1.media_url)
                    |> Enum.sort()

    links = ~w(
      https://www.youtube.com/watch?v=1
      https://www.youtube.com/watch?v=2
      https://www.youtube.com/watch?v=3
      https://www.youtube.com/watch?v=4
      https://www.youtube.com/watch?v=5
      https://www.youtube.com/watch?v=6
    )

    assert fetched_links == links
  end
end
