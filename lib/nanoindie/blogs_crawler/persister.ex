defmodule Nanoindie.BlogsCrawler.Persister do
  alias Nanoindie.{Song, Repo}
  require Ecto.Query

  def persist(songs, blog) do
    songs |> Enum.each(& persist_song(blog, &1))
  end

  defp persist_song(blog, song_params) do
    already_saved_song = Song
                         |> Ecto.Query.where(media_url: ^song_params.media_url)
                         |> Repo.one()

    song = already_saved_song || Song.changeset(%Song{}, song_params) |> Repo.insert!
    Song.link_blog(song, blog)
  end
end
