defmodule NanoindieWeb.SongController do
  use NanoindieWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", songs: ~w(cool_song awesome_song)
  end
end
