defmodule BullsAndCowsWeb.PageController do
  use BullsAndCowsWeb, :controller

  alias BullsAndCows.GameSupervisor

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def list_games(conn, _params) do
    games =
      :gproc.select([{:_, [], [:"$$"]}])
      |> Enum.map(fn [{_, _, {_, game_name}}, _, _] -> game_name end)

    conn
    |> render("games.html", games: games)
  end

  def create_game(conn, %{"name" => name}) do
    {:ok, game} = GameSupervisor.start_game(name)

    conn
    |> put_flash(:info, "You entered the name: " <> name)
    |> render("game.html", game: %{name: name, number: nil}, player: :player1)
  end

  def choose_number(conn, %{"game_name" => game_name, "number" => number, "player" => player}) do
    game_pid = GenServer.whereis(BullsAndCows.Game.via_tuple(game_name))
    {:ok, state_data} = BullsAndCows.Game.choose_number(game_pid, number, String.to_atom(player))

    conn
    |> render(
      "playground.html",
      game: %{name: game_name, number: number, player2: %{name: state_data.player2.name}},
      player: player,
      playerGuesses: Map.get(state_data, String.to_atom(player)).guesses
    )
  end

  def join_game(conn, %{"game_name" => game_name, "player_name" => player_name}) do
    pid = GenServer.whereis(BullsAndCows.Game.via_tuple(game_name))
    BullsAndCows.Game.add_player(pid, player_name)

    BullsAndCowsWeb.Endpoint.broadcast("game:" <> game_name, "player_added", %{
      message: "New player just joined: " <> player_name,
      player2Name: player_name
    })

    conn
    |> put_flash(:info, player_name <> " joined game of " <> game_name)
    |> render("game.html", game: %{name: game_name, number: nil}, player: :player2)
  end

  def guess_number(conn, %{
        "game_name" => game_name,
        "player" => player,
        "number" => number,
        "suggestion" => suggestion
      }) do
    game_pid = GenServer.whereis(BullsAndCows.Game.via_tuple(game_name))

    {:ok, state_data} =
      BullsAndCows.Game.guess_number(game_pid, String.to_atom(player), suggestion)

    BullsAndCowsWeb.Endpoint.broadcast("game:" <> game_name, "guesses_updated", %{
      player: player,
      playerGuesses: Map.get(state_data, String.to_atom(player)).guesses
    })

    conn
    |> render(
      "playground.html",
      game: %{name: game_name, number: number, player2: %{name: state_data.player2.name}},
      player: player,
      playerGuesses: Map.get(state_data, String.to_atom(player)).guesses
    )
  end
end
