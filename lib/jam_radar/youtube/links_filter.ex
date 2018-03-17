defmodule JamRadar.Youtube.LinksFilter do
  alias BlogFeedLinks.Link

  def filter(links) do
    filtered_links = Enum.reject links, fn(link) ->
      Regex.run(~r/list/, link.url)
    end

    Enum.uniq embed_urls(filtered_links) ++ watch_urls(filtered_links)
  end

  defp embed_urls(links) do
    filtered_links = Enum.filter links, fn(link) ->
      Regex.run(~r/youtube.com\/embed/, link.url)
    end

    Enum.map filtered_links, fn(link) ->
      url = link.url
            |> String.split("/")
            |> List.last
            |> String.split("?")
            |> List.first
            |> watch_url()

      %Link{link | url: url}
    end
  end

  defp watch_urls(links) do
    filtered_links = Enum.filter links, fn(link) ->
      Regex.run(~r/youtube.com\/watch/, link.url)
    end

    Enum.map filtered_links, fn(link) ->
      url = link.url
            |> String.split("&")
            |> List.first
            |> String.split("watch?v=")
            |> List.last
            |> watch_url()

      %Link{link | url: url}
    end
  end

  defp watch_url(youtube_code) do
    "https://www.youtube.com/watch?v=#{youtube_code}"
  end
end
