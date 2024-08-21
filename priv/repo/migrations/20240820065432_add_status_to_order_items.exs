defmodule Project2.Repo.Migrations.AddStatusToOrderItems do
  use Ecto.Migration

  def change do
    alter table(:order_items) do
      add :status, :string, default: "pending"
    end
  end
end
