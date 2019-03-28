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
    };
    this.selectCountry = this.selectCountry.bind(this);
    this.selectFrom = this.selectFrom.bind(this);
    this.selectTo = this.selectTo.bind(this);
    this.render = this.render.bind(this);
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

  render() {
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
        <Board select={this.selectCountry}/>

      </div>

  );
  }
}

export default App;
