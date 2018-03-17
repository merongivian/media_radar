defmodule JamRadar.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :song_id, references("songs")
      add :blog_id, references("blogs")

      timestamps()
    end

    create unique_index(:posts, [:song_id, :blog_id])
  end
end
