defmodule JamRadar.Song do
  use Ecto.Schema
  import Ecto.Changeset
  alias JamRadar.{Song, Blog, Post, Repo}


  schema "songs" do
    field :media_url, :string
    field :source, :string
    field :title, :string
    field :published_at, :utc_datetime

    many_to_many :blogs, Blog, join_through: Post

    timestamps()
  end

  @doc false
  def changeset(%Song{} = song, attrs) do
    song
    |> cast(attrs, [:title, :source, :media_url, :published_at])
    |> validate_required([:title, :source, :media_url, :published_at])
    |> unique_constraint(:media_url)
  end

  def link_blog(%Song{} = song, blog) do
    song_with_blogs = Repo.preload(song, :blogs)
    blogs = song_with_blogs.blogs ++ [blog]

    song_with_blogs
    |> change
    |> put_assoc(:blogs, blogs)
    |> Repo.update
  end

  def prefered_blog(%Song{} = song) do
    song
    |> Ecto.assoc(:blogs)
    |> Ecto.Query.first
    |> Repo.one
  end
end
