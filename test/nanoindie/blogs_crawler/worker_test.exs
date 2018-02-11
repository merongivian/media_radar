defmodule BlogsCrawler.WorkerTest do
  use Nanoindie.DataCase
  use ExUnit.Case, async: true

  import Nanoindie.Factory

  setup context do
    bypass = Bypass.open(port: 1234)
    feed_url = "http://localhost:#{bypass.port}"

    rss_response = File.read! "test/nanoindie/fixtures/#{context[:rss_fixture]}"

    Bypass.expect_once bypass, "GET", "/", &(Plug.Conn.resp(&1, 200, rss_response))

    {:ok, feed_url: feed_url, bypass: bypass}
  end

  @tag rss_fixture: "blog_rss_with_youtube_links.xml"
  test "fetch_songs/1", %{feed_url: feed_url} do
    blog = insert(:blog, feed_url: feed_url)

    Nanoindie.BlogsCrawler.Worker.start_link(blog)
    Nanoindie.BlogsCrawler.Worker.fetch_songs(blog)

    songs = blog.name
    |> String.to_atom()
    |> :sys.get_state()

    persisted_links = Nanoindie.Blog
                      |> Nanoindie.Repo.get_by(feed_url: feed_url)
                      |> Ecto.assoc(:songs)
                      |> Repo.all
                      |> Enum.map(& &1.media_url)
                      |> Enum.sort

    links = ~w(
      https://www.youtube.com/watch?v=1
      https://www.youtube.com/watch?v=2
      https://www.youtube.com/watch?v=3
      https://www.youtube.com/watch?v=4
      https://www.youtube.com/watch?v=5
      https://www.youtube.com/watch?v=6
    )

    assert persisted_links = links
  end

  @tag rss_fixture: "blog_rss_with_youtube_links.xml"
  test "fetch_songs/1 with songs already persisted" do
    blog = insert(:blog, feed_url: feed_url)

    insert(:song, media_url: "https://www.youtube.com/watch?v=1")
    insert(:song, media_url: "https://www.youtube.com/watch?v=4")

    Nanoindie.BlogsCrawler.Worker.start_link(blog)
    Nanoindie.BlogsCrawler.Worker.fetch_songs(blog)

    blog.name
    |> String.to_atom()
    |> :sys.get_state()

    persisted_links = Nanoindie.Blog
                      |> Nanoindie.Repo.get_by(feed_url: feed_url)
                      |> Ecto.assoc(:songs)
                      |> Repo.all
                      |> Enum.map(& &1.media_url)
                      |> Enum.sort

    links = ~w(
      https://www.youtube.com/watch?v=2
      https://www.youtube.com/watch?v=3
      https://www.youtube.com/watch?v=5
      https://www.youtube.com/watch?v=6
    )

    assert persisted_links = links
  end
end
