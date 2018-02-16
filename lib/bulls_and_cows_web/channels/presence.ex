defmodule BullsAndCowsWeb.Presence do
  use Phoenix.Presence,
    otp_app: :bulls_and_cows,
    pubsub_server: BullsAndCows.PubSub
end
