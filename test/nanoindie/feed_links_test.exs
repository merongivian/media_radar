defmodule FeedLinksTest do
  use ExUnit.Case, async: true

  setup context do
    bypass = Bypass.open(port: 1234)
    url = "http://localhost:#{bypass.port}"

    feed_path = "/blog"
    feed_url = "#{url}#{feed_path}"

    rss_response = File.read! "test/nanoindie/fixtures/#{context[:entries_fixture]}"

    Bypass.expect_once bypass, "GET", feed_path, &(Plug.Conn.resp(&1, 200, rss_response))

    {:ok, feed_url: feed_url, bypass: bypass}
  end

  @tag entries_fixture: "blog_rss_sample.xml"
  test "from_rss/1", %{feed_url: feed_url} do
    assert Enum.sort(FeedLinks.from_rss feed_url) == [
      "http://www.example.com/link1",
      "http://www.example.com/link2",
      "http://www.example.com/link3",
      "http://www.example.com/link4",
      "http://www.example.com/link5",
      "http://www.example.com/link6"
    ]
  end

  @tag entries_fixture: "blog_rss_sample.xml"
  test "from_rss_crawling/1", %{feed_url: feed_url, bypass: bypass} do
    Enum.each ~w(/one /two /three), fn (entry_path) ->
      entry_page = File.read! "test/nanoindie/fixtures/crawlable_pages/#{entry_path}.html"
      Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
    end

    assert Enum.sort(FeedLinks.from_rss_crawling feed_url) == [
      "http://www.example.com/link1",
      "http://www.example.com/link2",
      "http://www.example.com/link3",
      "http://www.example.com/link4",
      "http://www.example.com/link5",
      "http://www.example.com/link6"
    ]
  end

  @tag entries_fixture: "blog_page_sample.html"
  test "from_pure_crawling/2", %{feed_url: feed_url, bypass: bypass} do
    Enum.each ~w(/one /two), fn (entry_path) ->
      entry_page = File.read! "test/nanoindie/fixtures/crawlable_pages/#{entry_path}.html"
      Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
    end

    assert Enum.sort(FeedLinks.from_crawling feed_url, article_link_css: ".media-link") == [
      "http://www.example.com/link1",
      "http://www.example.com/link2",
      "http://www.example.com/link3",
      "http://www.example.com/link4"
    ]
  end
end
