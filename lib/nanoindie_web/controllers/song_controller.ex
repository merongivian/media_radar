defmodule NanoindieWeb.SongController do
  alias Nanoindie.{Song, Repo}
  use NanoindieWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", songs: Repo.all(Song)
  end
end
