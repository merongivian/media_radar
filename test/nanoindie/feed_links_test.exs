defmodule FeedLinksTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open(port: 1234)
    url    = "http://localhost:#{bypass.port}"

    feed_path = "/blog"
    feed_url = "#{url}#{feed_path}"

    rss_response = File.read! "test/nanoindie/fixtures/blog_rss_sample.xml"

    Bypass.expect_once bypass, "GET", feed_path, &(Plug.Conn.resp(&1, 200, rss_response))

    {:ok, bypass: bypass, url: url, feed_url: feed_url}
  end

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

  test "from_rss_crawling/1", %{bypass: bypass, url: url, feed_url: feed_url} do
    Enum.each ~w(/one /two /three), fn (sublink_path) ->
      sublink_page = File.read! "test/nanoindie/fixtures/crawlable_pages/#{sublink_path}.html"
      Bypass.expect_once bypass, "GET", sublink_path, &(Plug.Conn.resp(&1, 200, sublink_page))
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

  #test "from_pure_crawling/2" do
  #end
end

