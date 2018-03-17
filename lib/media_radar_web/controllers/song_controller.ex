defmodule MediaRadarWeb.SongController do
  alias MediaRadar.{Song, Blog, Repo}
  use MediaRadarWeb, :controller
  require Ecto.Query

  def index(conn, params) do
    blog  = params["blog_id"] && Repo.get_by(Blog, id: params["blog_id"])
    songs = if blog do
              Ecto.assoc(blog, :songs)
            else
              Song
            end
            |> Ecto.Query.order_by(desc: :published_at)
            |> Ecto.Query.limit(200)
            |> Repo.all()

    render conn, "index.html", songs: songs, blog: blog
  end
end
