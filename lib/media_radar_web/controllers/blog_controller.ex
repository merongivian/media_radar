defmodule MediaRadarWeb.BlogController do
  alias MediaRadar.{Blog, Repo}
  use MediaRadarWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", blogs: Repo.all(Blog)
  end
end
