defmodule NanoindieWeb.Router do
  use NanoindieWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NanoindieWeb do
    pipe_through :browser # Use the default browser stack

    get  "/", SongController, :index

    resources "/blogs", BlogController, only: ~w(index)a
    resources "/songs", SongController, only: ~w(index)a
  end

  # Other scopes may use custom stacks.
  # scope "/api", NanoindieWeb do
  #   pipe_through :api
  # end
end
