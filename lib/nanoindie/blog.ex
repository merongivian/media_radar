defmodule Nanoindie.Blog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Nanoindie.Blog


  schema "blogs" do
    field :article_link_css, :string
    field :country, :string
    field :feed_url, :string
    field :logo_url, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Blog{} = blog, attrs) do
    blog
    |> cast(attrs, [:feed_url, :name, :country, :logo_url, :article_link_css])
    |> validate_required([:name, :feed_url])
    |> unique_constraint(:name)
    |> unique_constraint(:feed_url)
    |> unique_constraint(:logo_url)
  end
end
