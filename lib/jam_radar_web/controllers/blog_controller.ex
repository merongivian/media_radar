defmodule JamRadarWeb.BlogController do
  alias JamRadar.{Blog, Repo}
  use JamRadarWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", blogs: Repo.all(Blog)
  end
end
