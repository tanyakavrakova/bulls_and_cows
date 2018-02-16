defmodule BullsAndCows.Counter do
  @moduledoc """
  This is the module that count the amount of bulls and cows 
  when a suggestion is made.
  """

  import BullsAndCowsWeb.Gettext

  @doc """
  The API function of the module.

  ## Examples

    iex> BullsAndCows.Counter.count(1234, 1432)
    %{bulls: 2, cows: 2}

  """
  def count(number_to_guess, suggestion)
      when is_integer(number_to_guess) and is_integer(suggestion) do
    %{
      bulls: count_bulls(Integer.digits(number_to_guess), Integer.digits(suggestion), 0),
      cows: count_cows(tuplize(number_to_guess), tuplize(suggestion), 0)
    }
  end

  def count(_, _) do
    {:error, dgettext("errors", "Invalid input")}
  end

  defp count_bulls([], [], result), do: result
  defp count_bulls([h | t1], [h | t2], result), do: count_bulls(t1, t2, result + 1)
  defp count_bulls([_ | t1], [_ | t2], result), do: count_bulls(t1, t2, result)

  defp count_cows([], _, result), do: result

  defp count_cows([{pos, num} | tail], list, result),
    do: count_cows(tail, list, result + is_cow({pos, num}, list))

  defp is_cow(_, []), do: 0
  defp is_cow({pos, num}, [{pos, num} | tail]), do: is_cow({pos, num}, tail)
  defp is_cow({_, num}, [{_, num} | _]), do: 1
  defp is_cow({pos, num}, [{_, _} | tail]), do: is_cow({pos, num}, tail)

  defp tuplize(number), do: tuplize(Integer.digits(number), 1)
  defp tuplize([], _), do: []
  defp tuplize([head | tail], counter), do: [{counter, head} | tuplize(tail, counter + 1)]
end
