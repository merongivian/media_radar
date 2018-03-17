defmodule MediaRadar.BlogsCrawler.Worker do
  alias MediaRadar.BlogsCrawler.{Fetcher, Persister, Titleizer}

  use GenServer

  def start_link(blog) do
    GenServer.start_link(__MODULE__, [], name: String.to_atom(blog.name))
  end

  def process(blog) do
    GenServer.cast(String.to_atom(blog.name), {:process, blog})
  end

  def handle_cast({:process, blog}, _songs) do
    songs = blog
            |> Fetcher.fetch()
            |> Titleizer.set_titles()

    Persister.persist(songs, blog)

    {:noreply, songs}
  end
end
