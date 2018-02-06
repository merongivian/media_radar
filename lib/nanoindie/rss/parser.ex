defmodule Rss.Parser do
  def parse(raw_feed) do
    raw_feed
    |> entry_nodes()
    |> Enum.map(&Rss.Entry.create/1)
  end

  def node_value(node, subnode_name) do
    node
    |> Floki.find(subnode_name)
    |> Enum.map(&node_value/1)
  end
  def node_value({_, _, [value]}) when is_binary(value), do: value
  def node_value({_, _, value}), do: value
  def node_value(_), do: ""

  defp entry_nodes(main_node) do
    Floki.find(main_node, "entry, item")
  end
end
