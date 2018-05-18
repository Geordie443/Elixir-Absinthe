# ---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
# ---
defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlate.{Menu, Repo}

  query do
    @desc "The list of available items of the menu"
    field :menu_items, list_of(:menu_item) do
      resolve(fn _, _, _ ->
        {:ok, Repo.all(Menu.Item)}
      end)
    end
  end

  @desc "Individual Menu Items"
  object :menu_item do
    field(:id, :id, description: "ID of item")
    field(:name, :string, description: "Name of item")
    field(:description, :string, description: "Description of item")
    field(:price, :float, description: "Price of item")
    field(:added_on, :string, description: "Date added to menu of item")
  end
end
