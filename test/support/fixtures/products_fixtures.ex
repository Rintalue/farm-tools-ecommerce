defmodule Project2.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Project2.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image_url: "some image_url",
        name: "some name",
        price: "120.5"
      })
      |> Project2.Products.create_product()

    product
  end
end
