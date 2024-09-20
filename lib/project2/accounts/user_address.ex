defmodule Project2.Accounts.UserAddress do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_addresses" do
    field :full_name, :string
    field :phone_number, :string
    field :shipping_address, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string
    belongs_to :user, Project2.Accounts.User

    timestamps()
  end

  def changeset(user_address, attrs) do
    user_address
    |> cast(attrs, [
      :full_name,
      :phone_number,
      :shipping_address,
      :city,
      :state,
      :zip_code,
      :user_id
    ])
    |> validate_required([
      :full_name,
      :phone_number,
      :shipping_address,
      :city,
      :state,
      :zip_code,
      :user_id
    ])
  end
end
