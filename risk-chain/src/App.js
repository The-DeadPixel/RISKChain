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
      phase: 0,
      hilite: ''
    };
    this.selectCountry = this.selectCountry.bind(this);
    this.selectFrom = this.selectFrom.bind(this);
    this.selectTo = this.selectTo.bind(this);
    this.render = this.render.bind(this);
    this.getTestBoard = this.getTestBoard.bind(this);
    this.makeSelect = this.makeSelect.bind(this);
    this.getSubmitButton = this.getSubmitButton.bind(this);
    this.nextPhase = this.nextPhase.bind(this);
    this.getControllTitle = this.getControllTitle.bind(this);
  }

  selectCountry(country) {
    console.log(country);
    if(!this.state.type){
      this.setState({from:country}, () => {
        console.log('from country state CB:', this.state);
      });
    }else{
      this.setState({to:country}, () => {
        console.log('to country state CB:',this.state);
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
            troops: 6
          },
          3:{
            owner: player3,
            troops: 4
          },
          4:{
            owner: player2,
            troops: 2
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
        turn: player2,
        phase: 0,
        opponents: [player1, player3]

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
  nextPhase(){
    this.setState({ phase: (this.state.phase+1)%3 });
  }
  getControllTitle(){
    return (this.state.phase === 0 ? 'Placement Phase' : ( this.state.phase ===1 ? 'Attack Phase': 'Movement Phase' ) );
  }
  getSubmitButton(){
    return (<button onClick={(this.state.phase === 0 ? this.nextPhase : ( this.state.phase ===1 ? this.nextPhase: this.nextPhase ) )} > {(this.state.phase === 0 ? 'Deploy' : ( this.state.phase ===1 ? 'Launch Attack': 'Move Reinforcements' ) )}</button>);
  }
  render() {
    //console.log(this.state.hilite);

    return (
      <div className="App">
        <table width="100%" height="1000">
          <td width="20%" height="100%">
            <tr>
              {this.getControllTitle()}
            </tr>
            <tr>
              <input type={'range'}/>
            </tr>
            <tr>
              <button onClick={console.log}>Add</button>
            </tr>
            <tr>
              <p className={'scrollBox'}> Here is where we can put a list of all of the attacks Here is where we can put a list of all of the attacks Here is where we can put a list of all of the attacks Here is where we can put a list of all of the attacks</p>
              </tr>
            <tr>
              {this.getSubmitButton()}
            </tr>
          </td>
          <td width="80%" height="100%">
        <Board select={this.selectCountry} board={this.getTestBoard()} makeSelect={this.makeSelect} selections={this.state.hilite} />
          </td>
        </table>
      </div>

  );
  }

  /**
   * <div className="App">
   <table width="100%" height="1000">
   <td width="20%" height="100%">
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
   </td>
   <td width="80%" height="100%">
   <Board select={this.selectCountry} board={this.getTestBoard()} makeSelect={this.makeSelect} selections={this.state.hilite} />
   </td>
   </table>
   </div>
   *
   *
   */

}

export default App;
