defmodule BullsAndCows.Rules do
  alias __MODULE__

  defstruct state: :initialized,
            player1: :number_not_chosen,
            player2: :number_not_chosen

  def new(), do: %Rules{}

  def check(%Rules{state: :initialized} = rules, :add_player),
    do: {:ok, %Rules{rules | state: :players_set}}

  def check(%Rules{state: _} = rules, {:choose_number, player}) do
    case Map.fetch!(rules, player) do
      :number_chosen -> :error
      :number_not_chosen -> check(rules, {:number_chosen, player})
    end
  end

  def check(%Rules{state: _} = rules, {:number_chosen, player}) do
    rules = Map.put(rules, player, :number_chosen)

    case both_players_numbers_chosen?(rules) do
      true -> {:ok, %Rules{rules | state: :player1_turn}}
      false -> {:ok, rules}
    end
  end

  def check(%Rules{state: :player1_turn} = rules, {:guess_number, :player1}),
    do: {:ok, %Rules{rules | state: :player2_turn}}

  def check(%Rules{state: :player1_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(%Rules{state: :player2_turn} = rules, {:guess_number, :player2}),
    do: {:ok, %Rules{rules | state: :player1_turn}}

  def check(%Rules{state: :player2_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(_state, _action), do: :error

  defp both_players_numbers_chosen?(rules),
    do: rules.player1 == :number_chosen && rules.player2 == :number_chosen
end
