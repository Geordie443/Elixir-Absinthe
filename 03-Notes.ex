defmodule Ch3 do
  def menu do
    name = "name"

    section1 = '''

    - GraphQL defines input as part of the API schema and supports type validations as a core feature.
    - GraphQL documents are comprised of fields. The user lists fields they want to use and the schema uses its definition of those fields to resove the pieces of data that match.
    - Users can supply field arguements; a way for them to provide user input to fields that can be used to parameterize their queries.
    - Filtering menu items is an important feature of GraphQl, therefore it is important to keep resolvers as highly readable.
    - in the resolve fn, the code can account for both no arguements supplied as well as arguements being used as follows:
      
        _, %{matching: name}, _ when is_binary(name) -> #supplied arguements allow this query to be more specific
          query = from (t in Menu.Item, where: ilike(t.name, ^"%#{name}"))
          {:ok, Repo.all(query)}

        _, _, _ -> # original resolver that acts as a fall-through match
          {:ok, Repo.all(Menu.Item)} 

    - the "query = from" line utilizes some Ecto.Query macros
    - the goal of this line is to query menu items where the items filter by the user supplied "name"
    - ilike(string,search) : searches for search in string in a case sensitive fashion, specific to ecto query

    - Writing resolvers as anonymous functions can have negative side-effects on a schemas readability
    - It is a good habbit to extract the resolver into a new module
    - the filtering logic for the query will be moved to PlateSlate.Menu in this case:

    defmodule PlateSlateWeb.Resolvers.Menu do
        alias PlateSlate.Menu

        def menu_items(_, args, _) do
            {:ok, Menu.list_items(args)}
        end
    end

    - The def menu_items() function takes 3 arguements and uses the second arguement for the filtering logic
    - PlateSlate.Menu.list_items/1 is being called, so that is the next piece of logic that must be understood:

    def list_items(%{matching: name}) when is_binary(name) do
        Item
        |> where([m], ilike(m.name, ^"%#{name}%")) 
        |> Repo.all
    end

    def list_items(_) do
        Repo.all(Item)
    end

    - there are two listed definitions for list_items, one for a supplied arg and one without
    - the one with the supplied arguement takes place when name (which must be binary) is supplied
    - it finds the items where m is an individual item and the name field of the item must match the name arguement
    - the definition with no arguement lists all repo items with no filtering taking place

    - though it takes extra steps to add resolver modules which call functions from other modules, its important to set up a solid seperation of concerns early on
    - a resolvers jub is to mediate between the input that a user sends to GrapghQL API and the buisness logic that needs to be called in order to service the request
    - as an application gets larger, it is advantageous to keep the resolver and the domain buisness logic as seperate enteties

    - now that the proper resolver and menu_items function is written, the schema must be updated to account for the logic it used to handle being used elsewhere
    - new schema query:

    query do
        field :menu_items, list_of(:menu_item) do
            arg :matching, :string
            resolve &Resolvers.Menu.menu_items/3
        end
    end

    - the capture operator is used to allow the query to use the menu_items function and supply it with the arguement :matching of scalar type :string 
    - the new query accounts for both an arguement being used and no arguement as well since it uses the menu_item definition which then uses the list_item definition which descriminates between an arguement and no arguement

    - as of this point, there is an officially defined field arguement

    '''

    section2 = '''

    - GraphQL can provide arguement values for an arguement in 2 ways:
        - document literals
        - variables
    - using document literals, values are directly embedded inside the GraphQL document. This approach works well for static documents. 
    - here is a query that uses a document literal for a matcing: arguement to retrieve menu items with the name "rue":
    {
        menuItems(matching: "rue"){
            name
        }
    }

    - arguement values are given after the arguement name and a color. The literal for string is double quotes
    - to test this query, do the following line:
    - cd into the basic mix directory and run mix.deps.get mixthen supply the path to the menu_items_test.exs
    $ mix test test/plate_slate_web/schema/query/menu_items_test.exs
    - the test looks as follows:

    @query """
    {
        menuItems(matching: "rue") {
        name
        }
    }
    """
    test "menuItems field returns menu items filtered by name" do
        response = get(build_conn(), "/api", query: @query)
        assert json_response(response, 200) == %{
            "data" => %{
                "menuItems" => [
                    %{"name" => "Rueben"},
                ]
            }
        }
    end

    - this test searches the menuItem with the name "Rueben" for the string defined by matching in the query
    - if the matching: string is found within "Rueben", the test will pass

    - there is also a test for checking to make sure that the an value that has no match is accounted for correctly and can aslo be found in:
    test/plate_slate_web/schema/query/menu_items_test.exs

    - now both valid and invalid tests have been checked and are working
    - thought document literals are useful for testing, in the real world it is more useful to use variables that can be inserted dynamically so they do not have to be predefined.
    - GQL variables act as typed placeholders for values that will be sent along with the request. The variables are declared with thier types as well as their operation type
    - Operations:
        - GQL documents consist of one or more operations, which model something we want the GQL server to do. 
        - query operation is designated by an outer set of curly braces like such:
        {
            menuItems { name }
        }
        - This notation is shorthand for this 

        query {
            menuItems { name }
        }

        - when defining variables, it is important to be verbose and fully declare the operation. 
        - Here is a menu item query operation with a definition for a variable that will be used

        query ($term: String){
            menuItems(matching : $term){
                name
            }
        }

        - $term is the variable used for the matching arguement
        - variable delcarations are provided directly before the curly braces that start the body of an operation and are also inside parenthesis.
        - $variable names start with a $ and their GQL types follow after a : and a space. If declaring mutiple variables, they must be comma seperated
        - Important note:
            snake_cased
            CamelCased
        - Absinthe uses snake_cased atom identifiers for GQL types, in GQL itself, canonical GQL type names like String are used, which are CamelCased.
        - in the test designed to test if the variable is being passed in correctly, $term is defined as follows:
         
        @query """
        query ($term: String) {
            menuItems(matching: $term) {
                name
            }
        }
             """
        @variables %{"term" => "rue"}

        - the value of term is being passed along in variables.
        - the get requests in the test is as follows:
        get(build_conn(), "/api", query: @query, variables: @variables)

        GraphiQL responds with a post request that looks something like:

        {
            "query": "query ($term: String) { menuItems(matching: $term) { name } }",
            "variables": "{\"term\": \"rue\"}"
        }


    '''

    section3 = '''

    Enumeration is a special type of scalar that has a defined, finite set of values. Examples:
    - Shirt Sizes: S, M, L 
    - Colors: RED, GREEN, BLUE
    - Ordering: Asc, Desn 

    When looking at the query, we can add a new arguement called :order and use the enum :sort_order we declare 

    enum :sort_order do
        value(:asc)
        value(:desc)
    end

    :order being used in the query:

    field :menu_items, list_of(:menu_item) do
        arg :matching, :string
        arg :order, :sort_order   #here there is an arguement declared :order, using :sort_order as its type
        resolve &Resolvers.Menu.menu_items/3
    end

    Arguements are typically declared as NAME, TYPE. This way of decaring them is short hand for this:
    arg :order, type: :sort_order, default_value: :asc

    providing the default of :asc will provide that arguement if users do non
    The Query is modified to include the order arg:

    query do
        field :menu_items. list_of(:menu_item) do
            arg(:matching, :string)
            arg(:order, type: :sort_order, default_value: :asc)
            resolve(&Resolvers.Menu.menu_items/3)
        end
    end

    now that the query is updated to handle a new arguement, the resolver must also be updated
    - There are 2 cases that must be accounted for:
        - when :asc is given or it defaults to asc
        - when :desc is given

    the definition for list_items is updated to accomodate the addition of a query order:

    def list_items(filters) do
        filters
        |> Enum.reduce(Item, fn
        {_, nil}, query ->
            query
        {:order, order}, query ->
            from q in query, order_by: {^order, :name}
        {:matching, name}, query ->
            from q in query, where: ilike(q.name, ^"%#{name}%")
        end)
        |> Repo.all
    end    

    Ecto's order_by function uses :desc and :asc for ordering values so we take ^order as the first arguement
    ^order is getting the value matched to that atom

    There are tests in this section to test both ascending and descending ordered queries by checking the first item in the response
    For Example:
    - in the descending response: 
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
    Water is checked as the name of the only entry since it is the last alphabetically in the list of menu items,

    In taking a quick look at the query...

    @query """
    query ($order: SortOrder!) {
        menuItems(order: $order) {
            name
        }
    }
    """

    the value for $order is SortOrder, Absinthe uses CamelCase for the type identifiers. The exclaimation point after SortOrder designates that it is a mandatory variable.
    A document that does not recieve its variable requirements will not be executed by absinthe. 

    '''

    section4 = '''

    - It is possible to organize field arguements in case various filtering options wanted to be added to :menu_items field
    - It can be messy to add arguements directly onto the fields, but luckily GQL allows for input object types
    - an input_object with the atom :menu_item_filter can be used to group the various filters in a neat way
    - input objects model their members as fields and not args. They do not have a resolver of their own however, they are just there to model structure.
    - The syntax for the input object:

    @desc "filtering options as an input object for menu item list"
    input_object :menu_item_filter do
        
        @desc "matching a name"
        field :name, :string.

        @desc "matching a category name"
        field :category, :string
    end

    The input_object can be plugged into the field as an arguement so that it can be used as a filter:

    query do
        field :menu_items. list_of(:menu_item) do
            arg :filter, :menu_item_filter     #adding in the filter so that it can be used as an arguement 
            arg(:order, type: :sort_order, default_value: :asc)
            resolve(&Resolvers.Menu.menu_items/3)
        end
    end   

    - In order to support the filter, the PlateSlate.Menu.list_items/1 has to be reworked to build a query using either or both the :order and :filter arguements 

    def list_items(args) do
        args
        |> Enum.reduce(Item, fn 
            {:order, order}, query ->
                query |> order_by({^order, :name}) 
            {:filter, filter}, query ->
                query |> filter_with(filter)
        end)
        |> Repo.all
    end

    - this definition has been modified to order as well as filter.
    - order_by is predefined but filter_with is a definition that we must come up with. In order to do this however, we must utilize Enum.Reduce
    - Quick example of Enum.filter and enum.reduce...
    - Filter:
        iex> Enum.filter([1, 2, 3, 4], fn(x) -> rem(x, 2) == 0 end)
        -this will return [2,4] since all numbers from the list are passed into the fn(x), only the ones which evaluate to meet the condition remain.
        -the result is [2,4] since they are the only ones with a remainder of 0 when divided by 2
    - Reduce:
        iex> Enum.reduce([1, 2, 3], 10, fn(x, acc) -> x + acc end)
        - 10 is the accumulator, [1,2,3] are the different numbers added to the accumulator
        - the full list and accumulator are reduced to 1 number: 16
        - without the accumulator, the result would be 6
        iex> Enum.reduce(["a","b","5"],"hello", fn(x, acc) -> x <> acc end)
        - this list of strings and the accumulator get concatonated together to "5bahello"
    once the filter list_items is complete, a query with the filter can be carried out as follows:

    {
        menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
            name
        }
    }

    Alternatively: 

    @query """
    query ($filter: MenuItemFilter!) {
        menuItems(filter: $filter) {
            name
        }
    }
    """
    @variables %{filter: %{"tag" => "Vegetarian", "category" => "Sandwiches"}}


    '''

    section5 = '''



    '''

    section6 = '''



    '''

    section7 = '''



    '''

    title = "Chapter 3: Taking User Input"
    pages = "Pages: 31-57"
    h1 = "1 - Defining Field Arguments"
    h2 = "2 - Providing Field Argument Values"
    h3 = "3 - Using Enumeration Types"
    h4 = "4 - Modeling Input Objects"
    h5 = "5 - Making Arguments as Non Null"
    h6 = "6 - Creating Your Own Scalar Types"
    h7 = "7 - Moving Own"

    IO.puts('''
    \n#{title}
    #{pages}
    #{h1}
    #{h2}
    #{h3}
    #{h4}
    #{h5}
    #{h6}
    #{h7}
    0 - exit
    ''')

    selection = IO.gets("Which Section?: ") |> String.trim()

    case selection do
      "1" ->
        IO.puts("\n#{h1}")
        IO.puts("\n#{section1}")

      "2" ->
        IO.puts("\n#{h2}")
        IO.puts("\n#{section2}")

      "3" ->
        IO.puts("\n#{h3}")
        IO.puts("\n#{section3}")

      "4" ->
        IO.puts("\n#{h4}")
        IO.puts("\n#{section4}")

      "5" ->
        IO.puts("\n#{h5}")
        IO.puts("\n#{section5}")

      "6" ->
        IO.puts("\n#{h6}")
        IO.puts("\n#{section6}")

      "7" ->
        IO.puts("\n#{h7}")
        IO.puts("\n#{section7}")

      "0" ->
        IO.puts("Exit")
        System.halt(0)

      _ ->
        IO.puts("\nImproper Selection")
    end

    IO.gets("\nPress Enter to Make New Selection")
    menu()
  end
end

Ch3.menu()
