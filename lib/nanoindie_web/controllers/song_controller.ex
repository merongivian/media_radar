defmodule NanoindieWeb.SongController do
  alias Nanoindie.{Song, Blog, Repo}
  use NanoindieWeb, :controller

  def index(conn, params) do
    songs = if params["blog_id"] do
              Blog |> Repo.get_by(id: params["blog_id"]) |> Ecto.assoc(:songs) |> Repo.all()
            else
              Repo.all(Song)
            end

    render conn, "index.html", songs: songs
  end
end
