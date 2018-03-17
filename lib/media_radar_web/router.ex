defmodule MediaRadarWeb.Router do
  use MediaRadarWeb, :router

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

  scope "/", MediaRadarWeb do
    pipe_through :browser # Use the default browser stack

    get  "/", SongController, :index

    resources "/blogs", BlogController, only: ~w(index)a do
      resources "/songs", SongController, only: ~w(index)a
    end

    resources "/songs", SongController, only: ~w(index)a
  end

  # Other scopes may use custom stacks.
  # scope "/api", MediaRadarWeb do
  #   pipe_through :api
  # end
end
