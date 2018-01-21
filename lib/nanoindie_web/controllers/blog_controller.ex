defmodule NanoindieWeb.BlogController do
  use NanoindieWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", blogs: ~w(indiehoy muzikalia super45 disorder subterock)
  end
end
