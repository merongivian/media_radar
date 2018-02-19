defmodule Rss.Entry do
  defstruct link: "", content: "", published_at: nil
  alias Rss.Parser

  def create(entry_node) do
    %Rss.Entry{
      link: link(entry_node),
      content: content(entry_node),
      published_at: published_at(entry_node)
    }
  end

  def published_at(entry_node) do
    entry_node
    |> Parser.node_value("pubdate")
    # TODO: This is weird, the pattern match should extract the value from the array
    |> List.first
    |> parse_date()
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

  defp parse_date(date) do
    case Timex.parse("%a, %d %b %Y %H:%M:%S %z", :strftime) do
      {:error, _} -> DateTime.utc_now
      {:ok, date} -> date
    end
  end
end
