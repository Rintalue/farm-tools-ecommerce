defmodule Project2.Repo.Migrations.CreateUserAddresses do
  use Ecto.Migration

  def change do
    create table(:user_addresses) do
      add :full_name, :string
      add :phone_number, :string
      add :shipping_address, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_addresses, [:user_id])
  end
end
