defmodule BullsAndCows.Game do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  alias BullsAndCows.Rules

  @timeout 15000 * 60
  @players [:player1, :player2]

  def start_link(name) when is_binary(name),
    do: GenServer.start_link(__MODULE__, name, name: via_tuple(name))

  def init(name) do
    send(self(), {:set_state, name})
    {:ok, fresh_state(name)}
  end

  def add_player(game, name) when is_binary(name), do: GenServer.call(game, {:add_player, name})

  def choose_number(game, number, player),
    do: GenServer.call(game, {:choose_number, player, number})

  def guess_number(game, player, suggestion),
    do: GenServer.call(game, {:guess_number, player, suggestion})

  def via_tuple(name), do: {:via, :gproc, {:n, :l, {:game_name, name}}}

  defp fresh_state(name) do
    player1 = %{name: name, number: nil, guesses: []}
    player2 = %{name: nil, number: nil, guesses: []}
    %{player1: player1, player2: player2, rules: %Rules{}}
  end

  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1

  defp reply_success(state_data, reply) do
    # :dets.insert(:game_state, {state_data.player1.name, state_data})
    {:reply, {reply, state_data}, state_data}
  end

  def handle_call({:add_player, name}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, :add_player) do
      state_data
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, :state_data}
    end
  end

  def handle_call({:choose_number, player, number}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, {:choose_number, player}) do
      IO.inspect(rules)

      state_data
      |> update_number(player, number)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
    end
  end

  def handle_call({:guess_number, player, suggestion}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, {:guess_number, player}) do
      state_data
      |> update_guesses(player, suggestion)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
    end
  end

  defp update_guesses(state_data, player, suggestion) do
    result =
      BullsAndCows.Counter.count(
        String.to_integer(Map.get(state_data, opponent(player)).number),
        String.to_integer(suggestion)
      )

    put_in(state_data, [player, :guesses], [
      %{suggestion: suggestion, result: result} | Map.get(state_data, player).guesses
    ])
  end

  defp update_rules(state_data, rules), do: %{state_data | rules: rules}
  defp update_player2_name(state_data, name), do: put_in(state_data.player2.name, name)

  def update_number(state_data, player, number) do
    put_in(state_data, [player, :number], number)
  end
end
