defmodule NanoindieWeb.SongController do
  alias Nanoindie.{Song, Blog, Repo}
  use NanoindieWeb, :controller
  require Ecto.Query

  def index(conn, params) do
    songs = if params["blog_id"] do
              Blog
              |> Repo.get_by(id: params["blog_id"])
              |> Ecto.assoc(:songs)
            else
              Song
            end
            |> Ecto.Query.limit(200)
            |> Repo.all()

    render conn, "index.html", songs: songs
  end
end
