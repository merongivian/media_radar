defmodule Nanoindie.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :title, :string, null: false
      add :source, :string, null: false
      add :media_url, :string, null: false
      add :published_at, :utc_datetime, null: false

      timestamps()
    end

    create unique_index(:songs, [:title])
  end
end
