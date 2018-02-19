defmodule Youtube.UrlsFilterTest do
  use ExUnit.Case, async: true

  test "returning only embed and watch youtube links" do
    links  = [
      "https://www.spotify.com/embed",
      "https://www.youtube.com/embed/123",
      "https://www.youtube.com/watch?v=456",
      "https://www.youtube.com/other/any"
    ]

    assert Enum.sort(Youtube.UrlsFilter.filter links) == [
      "https://www.youtube.com/watch?v=123",
      "https://www.youtube.com/watch?v=456"
    ]
  end

  test "removing links with repeated video codes, transform into watch links" do
    links  = [
      "https://www.youtube.com/embed/123",
      "https://www.youtube.com/watch?v=123",
      "https://www.youtube.com/watch?v=456",
      "https://www.youtube.com/embed/456",
      "https://www.youtube.com/embed/679",
    ]

    assert Enum.sort(Youtube.UrlsFilter.filter links) == [
      "https://www.youtube.com/watch?v=123",
      "https://www.youtube.com/watch?v=456",
      "https://www.youtube.com/watch?v=679",
    ]
  end

  test "removing not needed params" do
    links = [
      "https://www.youtube.com/watch?v=444&feature=oembed&other=other",
      "https://www.youtube.com/watch?v=123",
      "https://www.youtube.com/embed/456?feature=oembed&other=other",
      "https://www.youtube.com/embed/789?rel=oembed?some"
    ]

    assert Enum.sort(Youtube.UrlsFilter.filter links) == [
      "https://www.youtube.com/watch?v=123",
      "https://www.youtube.com/watch?v=444",
      "https://www.youtube.com/watch?v=456",
      "https://www.youtube.com/watch?v=789"
    ]
  end

  test "removing list urls" do
    links = [
      "https://www.youtube.com/embed/789&list=123",
      "https://www.youtube.com/watch?v=789",
      "https://www.youtube.com/watch?v=456&list=some",
    ]

    assert Enum.sort(Youtube.UrlsFilter.filter links) == [
      "https://www.youtube.com/watch?v=789"
    ]
  end
end
