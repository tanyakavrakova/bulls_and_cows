import React, { Component } from 'react';
import {Socket} from "phoenix"

class Playground extends Component {

  constructor(props) {
    super(props);
    this.id = props.id;
    this.gameName = props.gameName;
    this.playerNumber = props.playerNumber;
    this.player2Name = props.player2Name;
    this.playerGuesses = props.playerGuesses;
    this.player = props.player;
    console.log("Player is " + props.player)
    this.handleInputChange = this.handleInputChange.bind(this);
  }

  updateName(newName) {
    this.name = newName;
  }

  componentDidMount() {
    let socket = new Socket("/socket", {});

    socket.connect();
    
    let channelName = "game:" + this.gameName;

    let channel = socket.channel(channelName , {});
    this.channel = channel;

    channel.join();
    
    channel.on("player_added", response => {
      this.player2Name = response.player2Name;
      this.setState({gameName: this.gameName, playerNumber: this.playerNumber, player2Name: response.player2Name, id: this.id});
    });

    channel.on("guesses_updated", response => {
      this.playerGuesses = response.playerGuesses;
      this.setState({gameName: this.gameName, playerNumber: this.playerNumber, player2Name: this.player2Name, id: this.id, playerGuesses: this.playerGuesses});
    });
  }

  handleInputChange(event) {
    this.channel.push("provide_suggestion", {"game_name": this.gameName, "player": this.player, "suggestion": this.suggestionInput.value})
  }

  render() {
    return (
      <div>
        <div><a>Player1: {this.gameName}</a>  | Player2: {this.player2Name} </div>
        <div>Your number is: {this.playerNumber}</div>
        <div>You are {this.player}</div>
        <div>Suggestion | Result</div>
          {this.playerGuesses.map(guess => {
            return (
              <div key={guess.suggestion}>Suggestion: {guess.suggestion} | Bulls: {guess.result.bulls} | Cows:{guess.result.cows}</div>
            )})}
          <form>
            <label>
              Suggestion:
              <input
                name="suggestion"
                type="text"
                ref={(input) => { this.suggestionInput = input; }} />
              <input
                type="button"
                value="Guess number"
                onClick={this.handleInputChange} />
            </label>
          </form>
        <br />
      </div>
  )}}

export default Playground;
