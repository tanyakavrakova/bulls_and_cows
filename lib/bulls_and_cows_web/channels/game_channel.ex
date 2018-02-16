defmodule BullsAndCowsWeb.GameChannel do
  use BullsAndCowsWeb, :channel

  alias BullsAndCows.{Game, GameSupervisor}
  alias BullsAndCowsWeb.Presence

  def join("game:" <> _player, _payload, socket) do
    {:ok, socket}
  end

  # def handle_in("hello", payload, socket) do
  #  {:reply, {:ok, payload}, socket}
  # end
  # def handle_in("hello", payload, socket) do
  #  push socket, "said_hello", payload
  #  {:noreply, socket}
  # end

  # def handle_in("hello", payload, socket) do
  #  {:reply, {:ok, payload}, socket}
  # end

  def handle_in("hello", payload, socket) do
    broadcast!(socket, "said_hello", payload)
    {:noreply, socket}
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
    #  with {:ok, state_data} <- Game.add_player(via(socket.topic), player) do
    #    
    #    broadcast! socket, "player_added", %{message:
    #      "New player just joined: " <> player, player2Name: player}
    #    {:noreply, socket}
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

  defp via("game:" <> player), do: Game.via_tuple(player)
end
