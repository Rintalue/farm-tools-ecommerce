defmodule Project2.ProductsTest do
  use Project2.DataCase

  alias Project2.Products

  describe "products" do
    alias Project2.Products.Product

    import Project2.ProductsFixtures

    @invalid_attrs %{description: nil, image_url: nil, name: nil, price: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{description: "some description", image_url: "some image_url", name: "some name", price: "120.5"}

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.description == "some description"
      assert product.image_url == "some image_url"
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{description: "some updated description", image_url: "some updated image_url", name: "some updated name", price: "456.7"}

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.description == "some updated description"
      assert product.image_url == "some updated image_url"
      assert product.name == "some updated name"
      assert product.price == Decimal.new("456.7")
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
