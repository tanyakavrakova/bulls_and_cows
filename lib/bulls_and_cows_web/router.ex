defmodule BullsAndCowsWeb.Router do
  use BullsAndCowsWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Phauxth.Authenticate)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BullsAndCowsWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    resources("/users", UserController)
    resources("/sessions", SessionController, only: [:new, :create, :delete])
    post("/game", PageController, :create_game)
    post("/join", PageController, :join_game)
    get("/games", PageController, :list_games)
    post("/choose_number", PageController, :choose_number)
    post("/guess_number", PageController, :guess_number)
  end
end
