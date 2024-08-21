defmodule Project2.Wishlists do
  alias Project2.Repo
  alias Project2.Wishlists.Wishlist
  import Ecto.Query, only: [from: 2]

  @spec add_to_wishlist(any(), any()) ::
          {:error, atom() | %{:errors => any(), optional(any()) => any()}} | {:ok, any()}
  def add_to_wishlist(user_id, product_id) do
    case Repo.get_by(Wishlist, user_id: user_id, product_id: product_id) do
      nil ->
        %Wishlist{}
        |> Wishlist.changeset(%{user_id: user_id, product_id: product_id})
        |> Repo.insert()

      _existing_wishlist ->
        {:error, "Item already in wishlist"}
    end
  end

  def remove_from_wishlist(user_id, product_id) do
    Repo.get_by(Wishlist, user_id: user_id, product_id: product_id)
    |> Repo.delete()
  end

  def list_wishlist_items(user_id) do
    from(w in Wishlist, where: w.user_id == ^user_id, preload: [:product])
    |> Repo.all()
  end
end
