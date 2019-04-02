import React, { Component } from 'react';
import Map from './components/Map';
import Board from './components/Board';

import './App.css';
import Controller from "./components/Controller";

class App extends Component {
  constructor(props) {
    super(props);
    this.state={
      from: 'Select a Country',
      to: 'Select a Country',
      type: false,
      troops:'',
      phase: '',
      hilite: ''
    };
    this.selectCountry = this.selectCountry.bind(this);
    this.selectFrom = this.selectFrom.bind(this);
    this.selectTo = this.selectTo.bind(this);
    this.render = this.render.bind(this);
    this.getTestBoard = this.getTestBoard.bind(this);
    this.makeSelect = this.makeSelect.bind(this);
  }

  selectCountry(country) {
    console.log(country);
    if(!this.state.type){
      this.setState({from:country}, () => {
        console.log(this.state);
      });
    }else{
      this.setState({to:country}, () => {
        console.log(this.state);
      })
    }
   }
  selectFrom(){
    console.log('testFrom');

    this.setState({type:false}, console.log.bind('selectFrom'));
  }
  selectTo(){
    console.log('testTo');
    this.setState({type:true}, console.log.bind('selectTo'));
  }
  makeSelect(lines) {
    console.log('making selection of hilites');
    this.setState({ hilite: lines }, this.render);
  }
  getTestBoard(){
    var player1 = '0xSEAN';
    var player2 = '0xLUKE';
    var player3 = '0xDAVE';
    return {
      board: {
        0:{
          0:{
            owner: player1,
            troops: 5
          },
          1:{
            owner: player1,
            troops: 4
          },
          2:{
            owner: player3,
            troops: 4
          },
          3:{
            owner: player3,
            troops: 4
          },
          4:{
            owner: player2,
            troops: 4
          },
          5:{
            owner: player1,
            troops: 4
          }
        },
        1: {
          0: {
            owner: player1,
            troops: 5
          },
          1: {
            owner: player2,
            troops: 4
          },
          2: {
            owner: player2,
            troops: 4
          },
          3: {
            owner: player2,
            troops: 4
          },
          4: {
            owner: player2,
            troops: 4
          },
          5: {
            owner: player2,
            troops: 4
          },
          6: {
            owner: player2,
            troops: 4
          },
          7: {
            owner: player2,
            troops: 4
          },
          8: {
            owner: player2,
            troops: 4
          },
          9: {
            owner: player2,
            troops: 4
          },
          10: {
            owner: player2,
            troops: 4
          },
          11: {
            owner: player2,
            troops: 4
          }
        },
        2: {
          0: {
            owner: player1,
            troops: 5
          },
          1: {
            owner: player2,
            troops: 4
          },
          2: {
            owner: player2,
            troops: 4
          },
          3: {
            owner: player2,
            troops: 4
          }
        },
        3: {
          0: {
            owner: player1,
            troops: 5
          },
          1: {
            owner: player2,
            troops: 4
          },
          2: {
            owner: player2,
            troops: 4
          },
          3: {
            owner: player2,
            troops: 4
          },
          4: {
            owner: player2,
            troops: 4
          },
          5: {
            owner: player2,
            troops: 4
          },
          6: {
            owner: player2,
            troops: 4
          }
        },
        4: {
          0: {
            owner: player1,
            troops: 5
          },
          1: {
            owner: player2,
            troops: 4
          },
          2: {
            owner: player2,
            troops: 4
          },
          3: {
            owner: player3,
            troops: 5
          },
          4: {
            owner: player2,
            troops: 4
          },
          5: {
            owner: player2,
            troops: 4
          },
          6: {
            owner: player2,
            troops: 4
          },
          7: {
            owner: player2,
            troops: 4
          },
          8: {
            owner: player2,
            troops: 4
          }
        },
        5: {
          0: {
            owner: player1,
            troops: 5
          },
          1: {
            owner: player2,
            troops: 4
          },
          2: {
            owner: player2,
            troops: 4
          },
          3: {
            owner: player2,
            troops: 4
          }
        }
      },
      config:{
        turn: player1,
        phase: 0

      },
      card:{
        hand: {
          0:{
            continent: 0,
            country: 4,
            type: 0
          },
          1:{
            continent: 3,
            country: 4,
            type: 0
          },
          2:{
            continent: 0,
            country: 1,
            type: 2
          },
          3:{
            continent: 3,
            country: 3,
            type: 2
          },
          4:{
            continent: 4,
            country: 0,
            type: 3
          },
          5:{
            continent: 0,
            country: 0,
            type: 1
          }
        }
      }
    }
  }
  render() {
    console.log(this.state.hilite);
    return (
      <div className="App">
        <div>
        <Controller
                    type={this.state.type}
                    phase={this.state.phase}
                    selectFrom={this.selectFrom}
                    selectTo={this.selectTo}
                    />
      </div>
        <div>
          <p> From: {this.state.from} To: {this.state.to}</p>
        </div>
        <Board select={this.selectCountry} board={this.getTestBoard()} makeSelect={this.makeSelect} selections={this.state.hilite} />

      </div>

  );
  }


}

export default App;
