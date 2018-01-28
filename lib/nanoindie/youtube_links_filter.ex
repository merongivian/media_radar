defmodule YoutubeLinksFilter do
  def filter(links) do
    filtered_links = Enum.reject links, fn(link) ->
      Regex.run(~r/list/, link)
    end

    Enum.uniq embed_links(filtered_links) ++ watch_links(filtered_links)
  end

  defp embed_links(links) do
    filtered_links = Enum.filter links, fn(link) ->
      Regex.run(~r/youtube.com\/embed/, link)
    end

    Enum.map filtered_links, fn(link) ->
      link
      |> String.split("/")
      |> List.last
      |> String.split("?")
      |> List.first
      |> watch_url()
    end
  end

  defp watch_links(links) do
    filtered_links = Enum.filter links, fn(link) ->
      Regex.run(~r/youtube.com\/watch/, link)
    end

    Enum.map filtered_links, fn(link) ->
      link
      |> String.split("&")
      |> List.first
      |> String.split("watch?v=")
      |> List.last
      |> watch_url()
    end
  end

  defp watch_url(youtube_code) do
    "https://www.youtube.com/watch?v=#{youtube_code}"
  end
end
