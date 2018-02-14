defmodule Youtube.Api do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.googleapis.com/youtube/v3"
  plug Tesla.Middleware.Query, [key: System.get_env("YOUTUBE_API_KEY")]
  plug Tesla.Middleware.JSON

  def video(id) do
    response = get("/videos",
                 query: [
                   part: "snippet",
                   id: id
                 ]
               )

    response.body
    |> Map.get("items")
    |> List.first()
    |> Map.get("snippet")
  end
end
