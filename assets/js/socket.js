// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {})
//{params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

function new_channel(subtopic, screen_name) {
  return socket.channel("game:" + subtopic, {screen_name: screen_name});
}

var game_channel = new_channel("moon", "moon")
function join(channel) {
  channel.join()
    .receive("ok", response => {
      console.log("Joined successfully!", response)
    })
  .receive("error", response => {
    console.log("Unable to join", response)
  })
}
join(game_channel)

  // Now that you are connected, you can join channels with a topic:
//let channel = socket.channel("topic:subtopic", {})
//channel.join()
//  .receive("ok", resp => { console.log("Joined successfully", resp) })
//  .receive("error", resp => { console.log("Unable to join", resp) })

function leave(channel) {
  channel.leave()
    .receive("ok", response => {
      console.log("Left successfully", response)
    })
  .receive("error", response => {
    console.log("Unable to leave", response)
  })
}

function say_hello(channel, greeting) {
  channel.push("hello", {"message": greeting})
    .receive("ok", response => {
      console.log("Hello", response.message)
    })
  .receive("error", response => {
    console.log("Unable to say hello to the channel.", response.message)
  })
}

function new_game(channel) {
  channel.push("new_game")
    .receive("ok", response => {
      console.log("New Game!", response)
    })
  .receive("error", response => {
    console.log("Unable to start a new game.", response)
  })
}

function add_player(channel, player) {
  channel.push("add_player", player)
    .receive("error", response => {
      console.log("Unable to add new player: " + player, response)
    })
}

//function guess_number(channel, )

game_channel.on("player_added", response => {
  console.log("Player Added", response)
})

game_channel.on("said_hello", response => {
  console.log("Hello Said", response)
})

say_hello(game_channel, "World!")

window.App = {
  new_game: new_game,
  add_player: add_player,
  game_channel: game_channel,
  socket: socket,
  say_hello: say_hello,
  join: join
}
export default socket
