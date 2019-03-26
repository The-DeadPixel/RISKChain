import React, { Component } from "react";
import { Button, Header, Icon, Modal, Form, Message } from "semantic-ui-react";
import web3 from "../web3";
import trojanSecret from "../trojanSecret";

export default class ListPlayers extends Component {
  state = {
    modalOpen: false,
    numPlayers: "",
    message: "",
    errorMessage: ""
  };
  
  handleOpen = async () => {
    this.setState({ modalOpen: true });
      const numPlayers = await trojanSecret.methods.memberCount().call();
      const message = await trojanSecret.methods.listPlayers().call();
      this.setState({ numPlayers });
      this.setState({ message });

  };

  handleClose = () => this.setState({ modalOpen: false });

  render() {
    return (
      <Modal
        trigger={
          <Button color="purple" onClick={this.handleOpen}>
            List all Players
          </Button>
        }
        open={this.state.modalOpen}
        onClose={this.handleClose}
      >
        <Header icon="browser" content="List All Players" />
        <Modal.Content>
          <h3>
            {this.state.message} are the registered Trojans.
            <br />
            <br />
            {this.state.numPlayers} names have
            been registered to play this game.
          </h3>
        </Modal.Content>
        <Modal.Actions>
          <Button color="red" onClick={this.handleClose} inverted>
            <Icon name="cancel" /> Close
          </Button>
        </Modal.Actions>
      </Modal>
    );
  }
}
