defmodule Youtube.UrlsFilter do
  def filter(urls) do
    filtered_urls = Enum.reject urls, fn(url) ->
      Regex.run(~r/list/, url)
    end

    Enum.uniq embed_urls(filtered_urls) ++ watch_urls(filtered_urls)
  end

  defp embed_urls(urls) do
    filtered_urls = Enum.filter urls, fn(url) ->
      Regex.run(~r/youtube.com\/embed/, url)
    end

    Enum.map filtered_urls, fn(url) ->
      url
      |> String.split("/")
      |> List.last
      |> String.split("?")
      |> List.first
      |> watch_url()
    end
  end

  defp watch_urls(urls) do
    filtered_urls = Enum.filter urls, fn(url) ->
      Regex.run(~r/youtube.com\/watch/, url)
    end

    Enum.map filtered_urls, fn(url) ->
      url
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
