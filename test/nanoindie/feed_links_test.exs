defmodule FeedLinksTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open
    url    = "http://localhost:#{bypass.port}"
    {:ok, bypass: bypass, url: url}
  end

  test "from_rss/1", %{bypass: bypass, url: url} do
    feed_path = "/blog"
    feed_url = "#{url}#{feed_path}"

    rss_response = File.read! "test/nanoindie/blog_rss_sample.xml"

    Bypass.expect_once bypass, "GET", feed_path, &(Plug.Conn.resp(&1, 200, rss_response))

    assert Enum.sort(FeedLinks.from_rss feed_url) == [
      "http://www.example.com/link1",
      "http://www.example.com/link2",
      "http://www.example.com/link3",
      "http://www.example.com/link4",
      "http://www.example.com/link5",
      "http://www.example.com/link6"
    ]
  end

  #test "from_rss_crawling/1" do
  #end

  #test "from_pure_crawling/2" do
  #end
end
