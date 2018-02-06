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
    Parser.node_value(entry_node, "link")
  end

  def content(entry_node) do
    content = Parser.node_value(entry_node, "content")

    if Enum.empty?(content) do
      encoded_content = entry_node
                        |> Parser.node_value()
                        |> Enum.find(&(elem(&1, 0) == "content:encoded"))
                        |> Parser.node_value()
      # need it in order to be used later with flatmap, refactor
      [encoded_content]
    else
      # should return just the string without the array
      content
    end
  end
end
