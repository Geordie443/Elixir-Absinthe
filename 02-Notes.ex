chapter2 = 2
chapter2Text = "Building a Schema"

IO.puts('''

~~~!!!~~~   Chapter #{chapter2}: #{chapter2Text}   ~~~!!!~~~

pages 15-28


Preparing the Application
Schema Module
Making a Query
Running Query in GraphQL
Testing Query
Moving On

$ elixir -- version
$ mix deps.get
$ mix ecto.setup


client example query:

{
	menuItems{
		name
	}
}

roughly translates to "give us the names of all the menu items"

type of JSON used in response

{
	"data": {
		"menuItems": {
			{"name": Reuben},
			{"name": Extreme Pizza},
			{"name": Muffuletta}
		}
	}
}

fire up interactive shell:
$ iex -S mix

In iex shell:

you can look at how the MenuItem obhject is modeled in the schema using:

Absinthe.Schema.lookup_type(PlateSlateWeb.Schema, "MenuItem")

Adding fields to an object. fields take identifier atoms that are built-in scalar types

Sample: 

object :menu_item do
	field :id, :id
	field :name, :string
	field :description, :string
end

Different scalar types:
:string
:integer
:float
:boolean
:null
:id

GraphQL query is the way that API users can ask for specific pieces of information
MenuItem is a GraphQL type that the user wishes to use
Two things must happen for the user to be able to use it:
	- A way for the user to request objects of the type
	- A way for the system to retrieve the associated data

Query for menu_items is as follows:

query do
    field(:menu_item, list_of(:menu_item))
  end

list_of is an Absinthe macro that indicates that a field returns a list of a specific type
 
list_of(:menu_item) is the same as...
%Absinthe.Type.List{of_type :menu_item}

QraphQL retrieves data for a field in a query using a resolver
the resolvers function is to retrieve data for a particular field

adding a resolver to the query is as follows:

alias PlateSlate.{Menu, Repo}

query do
	field :menu_items, list_of(:menu_item) do
		resolve fn _, _, _ ->
			{:ok, Repo.all(Menu.Item)}
		end
	end
end

alias allows us to shorten PlateSlte module name for readability
a function is passes to the resolver macro which has ignored arguements
the function returns an :ok tuple with the list of menu items, it lets absinthe know that the field was resolved successfully

Using GraphiQL:
an in-browser IDE for exploring graphQL
fire it up using:
$ mix phx.server

the following query will get the menuItems with name and identifier
{
	menuItems{
		id
		name
	}
}

The following is a query with an added description:
  query do
    @desc "The list of available items of the menu"
    field :menu_items, list_of(:menu_item) do
      resolve(fn _, _, _ ->
        {:ok, Repo.all(Menu.Item)}
      end)
    end
  end

ExUnit is a built-in elixir unit testing method. 
ExUnit tests to make sure the response has an HTTP status code of 200 and includes the expected json data
the following line is used to run the test:

$ mix test test/plate_slate_web/schema/query/menu_items_test.exs

if the test passes by confirming that the result is what the query is looking for:
Finished in X seconds
1 test, 0 failures

these tests can be used to make sure that changes in the code are not effecting the graphQL requests

Chapter Summary:

 - build foundation of graph QL system in elixir
 - use object type and query
 - use GraphiQL and ExUnit to tests

Do the challenges:
1) add another field to the GraphQL schema. Use a built in scalar type:
2) add descriptions for the fields inside MenuItem object type:

This two challenges were accomplished by modifying the object in schema.ex to be as follows:

  @desc "Individual Menu Items"
  object :menu_item do
    field(:id, :id, description: "ID of item")
    field(:name, :string, description: "Name of item")
    field(:description, :string, description: "Description of item")
    field(:price, :float, description: "Price of item")
    field(:added_on, :string, description: "Date added to menu of item")
  end

The GraphQL query was also changed to be:
	{
  	menuItems{
    	name
    	id
    	price
    	addedOn
  	}
	}

''')
