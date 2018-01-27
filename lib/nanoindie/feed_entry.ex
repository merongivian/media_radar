defmodule FeedEntry do
  defstruct link: "", content: ""

  def create(entry_node) do
    %FeedEntry{
      link: link(entry_node),
      content: content(entry_node)
    }
  end

  def link(entry_node) do
    FeedParser.node_value(entry_node, :link)
  end

  def content(entry_node) do
    content_node = FeedParser.node_value(entry_node, :content)

    if Enum.empty?(content_node) do
      FeedParser.node_value(entry_node, :"content:encoded")
    else
      content_node
    end
  end
end
