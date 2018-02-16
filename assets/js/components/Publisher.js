import React, { Component } from 'react';
import {Socket} from "phoenix"

class Publisher extends Component {
  //state={
  //  id: null,
  //  name: '',
  //  code: ''
  //}

  constructor(props) {
    super(props);
    this.id = props.id;
    this.name = props.name;
    this.code = props.code;
  }

  updateName(newName) {
    this.name = newName;
  }

  componentDidMount() {
    let socket = new Socket("/socket", {params: {token: window.userToken}})

    socket.connect()

    let channel = socket.channel("game:moon", {})

    channel.join()
      .receive("ok", response => { console.log("React Success", response) })
    
    channel.on("said_hello", response => {
      console.log("react said hello", response);
      console.log(this.name);
      this.name = "HELLO";
      //this.updateName(response.message);
      console.log(this);
      this.setState({name: response.message, code: this.code, id: this.id});
      //this.setState();
    })
  }

  render() {
    return (
      <div><a>{this.name}</a>  | {this.code} </div>
    ) 
  }
}

export default Publisher;
