defmodule BullsAndCows.GameSupervisor do
  use DynamicSupervisor

  alias BullsAndCows.Game

  def start_link(_options), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_game(name), do: DynamicSupervisor.start_child(__MODULE__, {Game, name})

  def stop_game(name) do
    :ets.delete(:game_state, name)
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  def terminate({:shutdown, :timeout}, state_data) do
    :ets.delete(:game_state, state_data.player1.name)
    :ok
  end

  def terminate(_reason, _state), do: :ok

  defp pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end
