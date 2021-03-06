defmodule HeimdallWeb.ApiController do
  use HeimdallWeb, :controller
  import Plug.Conn


  # this route takes one upc, and returns the upc with the check digit added
  # http://0.0.0.0:4000/api/add_check_digit/1234
  def add_check_digit(conn, params) do
    check_digit_with_upc = _calculate_check_digit(params["upc"])
    _send_json(conn, 200, check_digit_with_upc)
  end

  # this route takes a comma separated list and should add a check digit to each element
  # http://0.0.0.0:4000/api/add_a_bunch_of_check_digits/12345,233454,34341432
  def add_a_bunch_of_check_digits(conn, params) do
    check_digits_with_upc = String.split(params["upcs"], ",")
    |> Enum.map((fn upc -> _calculate_check_digit(upc) end))

    _send_json(conn, 200, check_digits_with_upc)
  end

  # these are private methods
  defp _calculate_check_digit(upc) do
    #this is where your code to calculate the check digit should go
    int_list = String.codepoints(upc) |> Enum.map((fn x -> elem(Integer.parse(x), 0) end))
    10 - rem(_odd_sum(int_list)*3 + _even_sum(int_list), 10)
  end

  defp _odd_sum(int_list) do
    odds = int_list |> Enum.with_index |> Enum.filter(fn x -> rem(elem(x, 1), 2) == 0 end)
    Enum.sum(odds |> Enum.map(fn x -> elem(x, 0) end))
  end

  defp _even_sum(int_list) do
    evens = int_list |> Enum.with_index |> Enum.filter(fn x -> rem(elem(x, 1), 2) != 0 end)
    Enum.sum(evens |> Enum.map(fn x -> elem(x, 0) end))
  end

  defp _parse_integers(x) do
    x = Integer.parse(x)
    elem(x, 0)
  end

  # this is a thing to format your responses and return json to the client
  defp _send_json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Poison.encode!(body))
  end

end