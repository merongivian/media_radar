defmodule Rss.Entry do
  defstruct link: "", content: ""
  alias Rss.Parser

  def create(entry_node) do
    %Rss.Entry{
      link: link(entry_node),
      content: content(entry_node)
    }
  end

  def link(entry_node) do
    Parser.node_value(entry_node, :link)
  end

  def content(entry_node) do
    content_node = Parser.node_value(entry_node, :content)

    if Enum.empty?(content_node) do
      Parser.node_value(entry_node, :"content:encoded")
    else
      content_node
    end
  end
end
