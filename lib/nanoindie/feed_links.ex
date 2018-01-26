defmodule FeedLinks do
  def from_rss(feed_url) do
    feed_url
    |> rss_contents()
    |> Enum.flat_map(&get_links/1)
  end

  def rss_contents(feed_url) do
    feed_url
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> get_rss_contents()
  end

  defp get_rss_contents(body) do
    parsed_body = Quinn.parse(body)

    get_rss_node_values(parsed_body, :content) ++
      get_rss_node_values(parsed_body, :"content:encoded")
  end

  defp get_rss_node_values(parsed_body, node_name) do
    parsed_body
    |> Quinn.find(node_name)
    |> Enum.flat_map fn(quinn_node) ->
      case quinn_node do
        %{value: value} -> value
        _ -> ""
      end
    end
  end

  defp get_links(content) do
    content
    |> Floki.find("a")
    |> Floki.attribute("href")
  end
end
