defmodule NanoindieWeb.BlogController do
  alias Nanoindie.{Blog, Repo}
  use NanoindieWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", blogs: Repo.all(Blog)
  end
end
