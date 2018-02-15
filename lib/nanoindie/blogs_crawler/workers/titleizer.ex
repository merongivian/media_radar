defmodule Nanoindie.BlogsCrawler.Workers.Titleizer do
  alias Nanoindie.BlogsCrawler.Workers.Fetcher

  def set_titles(blog) do
    blog
    |> Fetcher.get_songs()
    |> Enum.map(&set_title/1)
    |> Fetcher.update_songs(blog)
  end

  defp set_title(song) do
    title = song
            |> Map.get(:media_url)
            |> youtube_code()
            |> Youtube.Api.video()
            |> Map.get("title")

    %{song | title: title}
  end

  defp youtube_code(youtube_link) do
    youtube_link
    |> String.split("watch?v=")
    |> List.last
  end
end
