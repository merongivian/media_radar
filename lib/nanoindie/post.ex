defmodule Nanoindie.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Nanoindie.Post


  schema "posts" do
    field :blog_id, :integer
    field :song_id, :integer

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [])
    |> validate_required([])
  end
end
