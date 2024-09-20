defmodule Project2.Repo.Migrations.AddCategoryIdToProducts do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false

      timestamps()
    end

    alter table(:products) do
      add :category_id, references(:categories, on_delete: :nothing)
    end
  end
end
