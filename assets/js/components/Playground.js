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
  }

  updateName(newName) {
    this.name = newName;
  }

  componentDidMount() {
    let socket = new Socket("/socket", {});

    socket.connect();
    
    let channelName = "game:" + this.gameName;

    let channel = socket.channel(channelName , {});

    console.log("Playground logging: " + channelName);

    channel.join()
      .receive("ok", response => { console.log("React Success Playground", response) })
    
    channel.on("said_hello", response => {
      console.log("reacr said hello", response);
      console.log(this.name);
      this.name = "HELLO";
      this.updateName(response.message);
      console.log(this);
      this.setState({name: this.name, code: this.code, id: this.id});
    })

    channel.on("player_added", response => {
      console.log("React player added");
      console.log(response);
      console.log(response.player2Name);
      console.log(this);
      console.log(this.gameName);
      this.player2Name = response.player2Name;
      this.setState({gameName: this.gameName, playerNumber: this.playerNumber, player2Name: response.player2Name, id: this.id});
    });

    channel.on("guesses_updated", response => {
      this.playerGuesses = response.playerGuesses;
      this.setState({gameName: this.gameName, playerNumber: this.playerNumber, player2Name: this.player2Name, id: this.id, playerGuesses: this.playerGuesses});
    });
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
              <div>Suggestion: {guess.suggestion} | Bulls: {guess.result.bulls} | Cows:{guess.result.cows}</div>
            )})}
      </div>
  )}}

export default Playground;
