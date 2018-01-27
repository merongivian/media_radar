defmodule FeedLinks do
  def from_rss(feed_url) do
    feed_url
    |> rss_entries()
    |> Enum.flat_map(&(Map.get &1, :content))
    |> Enum.flat_map(&get_links/1)
  end

  def from_rss_crawling(feed_url) do
    feed_url
    |> rss_entries()
    |> Enum.flat_map(&(Map.get &1, :link))
    |> Enum.flat_map fn(link) ->
      link
      |> fetch_page()
      |> get_links()
    end
  end

  defp rss_entries(feed_url) do
    feed_url
    |> fetch_page()
    |> parse_rss()
  end

  defp fetch_page(url) do
    url
    |> HTTPoison.get!()
    |> Map.get(:body)
  end

  defp parse_rss(body) do
    body
    |> Quinn.parse(body)
    |> get_rss_entry_nodes()
    |> Enum.map fn(node) ->
      %{
        content: get_rss_entry_contents(node),
        link: get_rss_node_values(node, :link)
      }
    end
  end

  defp get_rss_node_values(node, subnode_name) do
    node
    |> Quinn.find(subnode_name)
    |> Enum.flat_map fn(quinn_node) ->
      case quinn_node do
        %{value: value} -> value
        _ -> ""
      end
    end
  end

  defp get_rss_entry_nodes(main_node) do
    get_rss_node_values(main_node, :entry) ++
      get_rss_node_values(main_node, :item)
  end

  defp get_rss_entry_contents(entry_node) do
    content_node = get_rss_node_values(entry_node, :content)

    if Enum.empty?(content_node) do
      get_rss_node_values(entry_node, :"content:encoded")
    else
      content_node
    end
  end

  defp get_links(content) do
    content
    |> Floki.find("a")
    |> Floki.attribute("href")
  end
end
