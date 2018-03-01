defmodule BullsAndCowsWeb.GameChannel do
  use BullsAndCowsWeb, :channel

  alias BullsAndCows.{Game, GameSupervisor}
  alias BullsAndCowsWeb.Presence

  def join("game:" <> _player, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_game", _payload, socket) do
    "game:" <> player = socket.topic

    case GameSupervisor.start_game(player) do
      {:ok, _pid} ->
        {:reply, :ok, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  def handle_in("add_player", player, socket) do
    case Game.add_player(via(socket.topic), player) do
      {:ok, state_data} ->
        broadcast!(socket, "player_added", %{
          message: "New player just joined: " <> player,
          player2Name: player
        })

        {:noreply, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: inspect(reason)}}, socket}

      :error ->
        {:reply, :error, socket}
    end
  end

  def handle_in(
        "provide_suggestion",
        %{"game_name" => game_name, "player" => player, "suggestion" => suggestion},
        socket
      ) do
    game_pid = GenServer.whereis(BullsAndCows.Game.via_tuple(game_name))

    {:ok, state_data} =
      BullsAndCows.Game.guess_number(game_pid, String.to_atom(player), suggestion)

    broadcast(socket, "guesses_updated", %{
      player: player,
      player1Guesses: Map.get(state_data, :player1).guesses,
      player2Guesses: Map.get(state_data, :player2).guesses
    })

    {:noreply, socket}
  end

  defp via("game:" <> player), do: Game.via_tuple(player)
end
