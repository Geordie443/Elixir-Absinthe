defmodule Ch3 do
  def menu do
    section1 = '''

    '''

    section2 = '''

    '''

    section3 = '''

    '''

    section4 = '''

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
    h2 = "2 - Providing Field Arguments"
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

      _ ->
        IO.puts("\nImproper Selection")
    end

    IO.gets("\nPress Enter to Make New Selection")
    menu()
  end
end

Ch3.menu()
