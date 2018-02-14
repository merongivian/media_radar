defmodule BlogsCrawler.Workers.FetcherTest do
  use Nanoindie.DataCase
  use ExUnit.Case, async: true

  alias Nanoindie.BlogsCrawler.Workers.Fetcher
  alias Nanoindie.Song

  import Nanoindie.Factory

  setup context do
    bypass = Bypass.open(port: 1234)
    feed_url = "http://localhost:#{bypass.port}"

    response = File.read! "test/nanoindie/fixtures/songs_fetching/#{context[:fixture]}"

    Bypass.expect bypass, "GET", "/", &(Plug.Conn.resp(&1, 200, response))

    blog = insert(:blog, feed_url: feed_url, article_link_css: context[:article_link_css])

    Enum.each [1, 4, 6], fn(song_id) ->
      song = insert(:song, media_url: "https://www.youtube.com/watch?v=#{song_id}")
      Song.link_blog(song, blog)
    end

    insert(:song, media_url: "https://www.youtube.com/watch?v=5")

    {:ok, feed_url: feed_url, bypass: bypass, blog: blog}
  end

  @tag fixture: "blog_rss/with_youtube_links.xml"
  test "fetch_songs/1 from rss", %{blog: blog} do
    Fetcher.start_link(blog)
    Fetcher.fetch_songs(blog)

    fetched_links = blog
                    |> Fetcher.get_songs()
                    |> Enum.map(& &1.media_url)
                    |> Enum.sort()

    links = ~w(
      https://www.youtube.com/watch?v=2
      https://www.youtube.com/watch?v=3
      https://www.youtube.com/watch?v=5
    )

    assert fetched_links == links
  end

  @tag fixture: "blog_rss/without_youtube_links.xml"
  test "fetch_songs/1 from crawled rss links", %{bypass: bypass, blog: blog} do
    Enum.each ~w(/one /two /three), fn (entry_path) ->
      entry_page = File.read! "test/nanoindie/fixtures/songs_fetching/blog_pages/#{entry_path}.html"
      Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
    end

    Fetcher.start_link(blog)
    Fetcher.fetch_songs(blog)

    fetched_links = blog
                    |> Fetcher.get_songs()
                    |> Enum.map(& &1.media_url)
                    |> Enum.sort()

    links = ~w(
      https://www.youtube.com/watch?v=2
      https://www.youtube.com/watch?v=3
      https://www.youtube.com/watch?v=5
    )

    assert fetched_links == links
  end

  @tag fixture: "blog_with_articles.html", article_link_css: ".song"
  test "fetch_songs/1 from crawled article links", %{bypass: bypass, blog: blog} do
    Enum.each ~w(/one /two /three), fn (entry_path) ->
      entry_page = File.read! "test/nanoindie/fixtures/songs_fetching/blog_pages/#{entry_path}.html"
      Bypass.expect_once bypass, "GET", entry_path, &(Plug.Conn.resp(&1, 200, entry_page))
    end

    Fetcher.start_link(blog)
    Fetcher.fetch_songs(blog)

    fetched_links = blog
                    |> Fetcher.get_songs()
                    |> Enum.map(& &1.media_url)
                    |> Enum.sort()

    links = ~w(
      https://www.youtube.com/watch?v=2
      https://www.youtube.com/watch?v=3
      https://www.youtube.com/watch?v=5
    )

    assert fetched_links == links
  end
end
