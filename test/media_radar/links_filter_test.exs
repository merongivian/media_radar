defmodule Youtube.LinksFilterTest do
  alias BlogFeedLinks.Link

  use ExUnit.Case, async: true

  test "returning only embed and watch youtube links" do
    links  = [
      %Link{url: "https://www.spotify.com/embed"},
      %Link{url: "https://www.youtube.com/embed/123"},
      %Link{url: "https://www.youtube.com/watch?v=456"},
      %Link{url: "https://www.youtube.com/other/any"}
    ]

    assert (links |> Youtube.LinksFilter.filter |> Enum.map(& Map.get(&1, :url)) |> Enum.sort) == [
     "https://www.youtube.com/watch?v=123",
     "https://www.youtube.com/watch?v=456"
    ]
  end

  test "removing links with repeated video codes, transform into watch links" do
    links  = [
      %Link{url: "https://www.youtube.com/embed/123"},
      %Link{url: "https://www.youtube.com/watch?v=123"},
      %Link{url: "https://www.youtube.com/watch?v=456"},
      %Link{url: "https://www.youtube.com/embed/456"},
      %Link{url: "https://www.youtube.com/embed/679"}
    ]

    assert (links |> Youtube.LinksFilter.filter |> Enum.map(& Map.get(&1, :url)) |> Enum.sort) == [
      "https://www.youtube.com/watch?v=123",
      "https://www.youtube.com/watch?v=456",
      "https://www.youtube.com/watch?v=679",
    ]
  end

  test "removing not needed params" do
    links = [
      %Link{url: "https://www.youtube.com/watch?v=444&feature=oembed&other=other"},
      %Link{url: "https://www.youtube.com/watch?v=123"},
      %Link{url: "https://www.youtube.com/embed/456?feature=oembed&other=other"},
      %Link{url: "https://www.youtube.com/embed/789?rel=oembed?some"}
    ]

    assert (links |> Youtube.LinksFilter.filter |> Enum.map(& Map.get(&1, :url)) |> Enum.sort) == [
      "https://www.youtube.com/watch?v=123",
      "https://www.youtube.com/watch?v=444",
      "https://www.youtube.com/watch?v=456",
      "https://www.youtube.com/watch?v=789"
    ]
  end

  test "removing list urls" do
    links = [
      %Link{url: "https://www.youtube.com/embed/789&list=123"},
      %Link{url: "https://www.youtube.com/watch?v=789"},
      %Link{url: "https://www.youtube.com/watch?v=456&list=some"}
    ]

    assert (links |> Youtube.LinksFilter.filter |> Enum.map(& Map.get(&1, :url)) |> Enum.sort) == [
      "https://www.youtube.com/watch?v=789"
    ]
  end
end
