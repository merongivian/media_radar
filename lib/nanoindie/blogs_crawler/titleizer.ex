defmodule Nanoindie.BlogsCrawler.Titleizer do
  def set_titles(songs) do
    songs |> Enum.map(&set_title/1)
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
