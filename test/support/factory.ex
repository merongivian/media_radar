defmodule MediaRadar.Factory do
  use ExMachina.Ecto, repo: MediaRadar.Repo

  def blog_factory do
    %MediaRadar.Blog{
      feed_url: sequence(:feed_url, &"www.indiehoy.com/feed-#{&1}"),
      name: sequence(:name, &"indiehoy-#{&1}"),
      logo_url: sequence(:logo_url, &"www.indiehoy.com/logo-#{&1}"),
      country: "AR"
    }
  end

  def song_factory do
    %MediaRadar.Song{
      title: "Awesome Song",
      source: "Youtube",
      media_url: sequence(:media_url, &"www.youtube.com/video-#{&1}"),
      published_at: DateTime.utc_now
    }
  end
end
