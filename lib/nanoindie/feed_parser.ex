defmodule FeedParser do
  def parse(raw_feed) do
    raw_feed
    |> Quinn.parse()
    |> entry_nodes()
    |> Enum.map(&FeedEntry.create/1)
  end

  def entry_nodes(main_node) do
    node_value(main_node, :entry) ++
      node_value(main_node, :item)
  end

  def node_value(node, subnode_name) do
    node
    |> Quinn.find(subnode_name)
    |> Enum.flat_map fn(quinn_node) ->
      case quinn_node do
        %{value: value} -> value
        _ -> ""
      end
    end
  end
end
