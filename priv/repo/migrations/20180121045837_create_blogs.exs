defmodule Nanoindie.Repo.Migrations.CreateBlogs do
  use Ecto.Migration

  def change do
    create table(:blogs) do
      add :feed_url, :string, null: false
      add :name, :string, null: false
      add :country, :string
      add :logo_url, :string
      add :article_link_css, :string

      timestamps()
    end

    create unique_index(:blogs, [:feed_url])
    create unique_index(:blogs, [:name])
  end
end
