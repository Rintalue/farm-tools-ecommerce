defmodule Project2.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :image_url, :string
      add :name, :string
      add :description, :text
      add :price, :decimal
      add :vendor_id, :integer
      add :category, :string

      timestamps(type: :utc_datetime)
    end
  end
end
