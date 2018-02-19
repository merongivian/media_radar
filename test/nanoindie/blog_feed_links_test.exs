defmodule BlogFeedLinksTest do
  use ExUnit.Case, async: true

  setup context do
    bypass = Bypass.open(port: 1234)
    feed_url = "http://localhost:#{bypass.port}"

    rss_response = File.read! "test/nanoindie/fixtures/#{context[:entries_fixture]}"

    Bypass.expect_once bypass, "GET", "/", &(Plug.Conn.resp(&1, 200, rss_response))

    {:ok, feed_url: feed_url, bypass: bypass}
  end

  describe "fetching from rss" do
    @describetag entries_fixture: "blog_rss_sample.xml"

    test "from_rss/1 urls", %{feed_url: feed_url} do
      urls = feed_url
             |> BlogFeedLinks.from_rss()
             |> Enum.map(fn(link) -> link.url end)

      assert urls == [
        "http://www.example.com/link1",
        "http://www.example.com/link2",
        "http://www.example.com/link3",
        "http://www.example.com/link4",
        "http://www.example.com/link5",
        "http://www.example.com/link6"
      ]
    end

    test "from_rss/1 published dates", %{feed_url: feed_url} do
      published_dates = feed_url
                        |> BlogFeedLinks.from_rss()
                        |> Enum.map(fn(link) -> link.published_at end)
      date_tuple = fn(date) -> {date.year, date.month, date.day} end

      first_date  = {2017, 8, 30}
      second_date = {2017, 8, 29}
      third_date  = {2017, 8, 28}

      assert date_tuple.(Enum.at published_dates, 0) == first_date
      assert date_tuple.(Enum.at published_dates, 1) == first_date
      assert date_tuple.(Enum.at published_dates, 2) == second_date
      assert date_tuple.(Enum.at published_dates, 3) == second_date
      assert date_tuple.(Enum.at published_dates, 4) == third_date
      assert date_tuple.(Enum.at published_dates, 5) == third_date
    end

    test "from_rss_crawling/1 urls", %{feed_url: feed_url, bypass: bypass} do
      Enum.each ~w(/one /two /three), fn (entry_path) ->
        entry_page = File.read! "test/nanoindie/fixtures/crawlable_pages/#{entry_path}.html"
        Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
      end

      urls = feed_url
             |> BlogFeedLinks.from_rss_crawling()
             |> Enum.map(fn(link) -> link.url end)

      assert urls == [
        "http://www.example.com/link1",
        "http://www.example.com/link2",
        "http://www.example.com/link3",
        "http://www.example.com/link4",
        "http://www.example.com/link5",
        "http://www.example.com/link6"
      ]
    end

    test "from_rss_crawling/1 published dates", %{feed_url: feed_url, bypass: bypass} do
      Enum.each ~w(/one /two /three), fn (entry_path) ->
        entry_page = File.read! "test/nanoindie/fixtures/crawlable_pages/#{entry_path}.html"
        Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
      end

      published_dates = feed_url
                        |> BlogFeedLinks.from_rss_crawling()
                        |> Enum.map(fn(link) -> link.published_at end)

      date_tuple = fn(date) -> {date.year, date.month, date.day} end

      first_date  = {2017, 8, 30}
      second_date = {2017, 8, 29}
      third_date  = {2017, 8, 28}

      assert date_tuple.(Enum.at published_dates, 0) == first_date
      assert date_tuple.(Enum.at published_dates, 1) == first_date
      assert date_tuple.(Enum.at published_dates, 2) == second_date
      assert date_tuple.(Enum.at published_dates, 3) == second_date
      assert date_tuple.(Enum.at published_dates, 4) == third_date
      assert date_tuple.(Enum.at published_dates, 5) == third_date
    end
  end

  @tag entries_fixture: "blog_page_sample.html"
  test "from_crawling/2", %{feed_url: feed_url, bypass: bypass} do
    Enum.each ~w(/one /two), fn (entry_path) ->
      entry_page = File.read! "test/nanoindie/fixtures/crawlable_pages/#{entry_path}.html"
      Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
    end

    urls = feed_url
           |> BlogFeedLinks.from_crawling(article_link_css: ".media-link")
           |> Enum.map(fn(link) -> link.url end)

    assert urls == [
      "http://www.example.com/link1",
      "http://www.example.com/link2",
      "http://www.example.com/link3",
      "http://www.example.com/link4"
    ]
  end
end
