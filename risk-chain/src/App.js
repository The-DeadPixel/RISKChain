import React, { Component } from 'react';
import Map from './components/Map';
import Board from './components/Board';

import './App.css';
import Controller from "./components/Controller";
import Preview from "./components/Preview";
import RiskContract from "./RiskContract";

class App extends Component {
  constructor(props) {
    super(props);
    this.state={
      from: 'Select a Country',
      to: 'Select a Country',
      type: false,
      troops:0,
      phase: 0,
      hilite: '',
      troopSelection: 'Selected Troops',
      remainingTroops: 6,
      pendingMove: [],
      setFromPreview: console.log,
      setToPreview: console.log
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
    this.sliderUpdate = this.sliderUpdate.bind(this);
    this.addButton = this.addButton.bind(this);
    this.getPreview = this.getPreview.bind(this);
    this.registerFrom = this.registerFrom.bind(this);
    this.registerTo = this.registerTo.bind(this);
    this.getScrollBox = this.getScrollBox.bind(this);
    this.getSlider = this.getSlider.bind(this);
  }

  selectCountry(selection) {
    let country = selection.country;
    console.log(selection);
    if(!this.state.type){
      this.state.setFromPreview(country, 'PATH');
      this.setState({from:country, troops:selection.troops, type: this.state.phase !=0 ? !this.state.type: this.state.type }, () => {
        console.log('from country state CB:', this.state);
      });
    }else{
      this.state.setToPreview(country, 'PATH');
      this.setState({to:country, type: !this.state.type }, () => {
        console.log('to country state CB:',this.state);
      });
    }
   }
  selectFrom(){
    console.log('testFrom.');
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
    /**
    var Board = await RiskContract.methods.getBoard().call();
    // Starting to plumb in some contract interaction...
    if( 0 ) {
      return Board;
    }
     */
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
        turn: player1,
        phase: 0,
        opponents: [player2, player3]

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
  async nextPhase(){
    //Send Data...
    let troops = 0;
    if(this.state.phase ===0) {
      console.log('Need to call troop placement');
      //Need to bake parameters for Place Troops Driver here
      // await RiskContract.methods.PlaceTroopsDriver().call();


    }else if( this.state.phase === 1) {
      console.log('Need to call Attack function');
      //Need to bake parameters for Attack Driver Here
     // await RiskContract.methods.AttackDriver().call();

    }else if( this.state.phase === 2) {
      console.log('Need to call troop movement function');
      //Need to bake parameters for TrfArmies Driver Here
     // await RiskContract.methods.TrfArmiesDriver().call();
      //This is where we need to set our remaining troops for the upcoming turn
      troops = 10;

    }else{
      console.log('Found ourselves in some inconsistant state, check nextPhase()');

    }
    // We also need to make a call on getBoard and update the board here when we move to the next phase.

    /**
     *     var Board = await RiskContract.methods.getBoard().call();
     *      set State on the correct component to Board... might have to plumb in a reference...
     */
    this.setState({ phase: (this.state.phase+1)%3 , pendingMove: [], remainingTroops: troops});
  }
  getControllTitle(){
    return (this.state.phase === 0 ? 'Placement Phase' : ( this.state.phase ===1 ? 'Attack Phase': 'Movement Phase' ) );
  }
  getSubmitButton(){
    return (<button onClick={(this.state.phase === 0 ? this.nextPhase : ( this.state.phase ===1 ? this.nextPhase: this.nextPhase ) )} > {(this.state.phase === 0 ? 'Deploy' : ( this.state.phase ===1 ? 'Launch Attack': 'Move Reinforcements' ) )}</button>);
  }
  sliderUpdate(event) {
    console.log(event.target.value);
    this.setState({ troopSelection: event.target.value });
  }
  addButton() {
    // add From, To, Troops to list, based on phase.
    if((this.state.troopSelection.localeCompare('Selected Troops')===0 || this.state.troopSelection <= 0) && this.state.phase == 0){
      console.log('No troops selected yet');
      return;
    }
    let troops = this.state.troopSelection;
    if(this.state.phase == 0 && this.state.remainingTroops < troops) {
      troops = this.state.remainingTroops;
    }

    let update = [];
    let tmpMoves = this.state.pendingMove;
    console.log(tmpMoves);
    if(this.state.phase == 0) {
       update =  tmpMoves.push({ type: this.state.phase, country: this.state.from, troops: troops});
    } else {
      update =  tmpMoves.push({ type: this.state.phase, from: this.state.from, to: this.state.to, troops: troops });
    }
    console.log(update);
    this.setState({ pendingMove: tmpMoves, remainingTroops: this.state.remainingTroops - troops }, () => {console.log(this.state)});
  }
  registerFrom(func) {
    console.log('register from');
    this.setState({ setFromPreview: func});
  }
  registerTo(func) {
    console.log('register to');

    this.setState({ setToPreview: func});
  }
  getPreview() {
    let preViewTag;
    if(this.state.phase === 0 ){
       return (<div><p>{'Remaining Reinforcements: '+this.state.remainingTroops}</p><Preview name={this.state.from} type={'To'} register={this.registerFrom}/></div>);
    }else{
      preViewTag = (<div><Preview name={this.state.from} type={'From'} register={this.registerFrom} /><Preview name={this.state.to} type={'To'} register={this.registerTo} /></div>);
    }
    return preViewTag;
  }
  getScrollBox() {
    let boxTag='';

    this.state.pendingMove.forEach((element) => {
      if(element.type == 0){
        boxTag +=  element.country +' + '+ element.troops+'\n';

      }else{
        boxTag += element.from +' '+ element.troops+' -> '+element.to+'\n';

      }
    });

    boxTag = (<p className={'scrollBox'}> {boxTag} </p>);
    //console.log(boxTag);
    return boxTag;

  }
  getSlider() {
    return (<div><p>{0}</p>
        <input type={'range'} min={0} max={this.state.phase == 0 ? this.state.remainingTroops : this.state.troops} onChange={this.sliderUpdate}/>
    <p>{this.state.phase == 0 ? this.state.remainingTroops : this.state.troops}</p></div>
  );
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
              {this.getPreview()}
            </tr>
            <tr>
              {this.getSlider()}
            </tr>
            <tr>
              <button onClick={this.addButton}>Add {this.state.troopSelection}</button>
            </tr>
            <tr className={'display-linebreak'}>
              {this.getScrollBox()}
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
