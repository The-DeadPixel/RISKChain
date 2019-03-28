import React, { Component } from 'react';
import Map from './components/Map';
import Board from './components/Board';

import './App.css';

class App extends Component {
  constructor(props) {
    super(props);
    this.state={
      from: 'Test',
      to: '',
      troops:'',
      phase: ''
    };
    this.selectCountry = this.selectCountry.bind(this);
  }

  selectCountry(country) {
    console.log(country);
    this.setState({from:country});
  }

  render() {
    return (
      <div className="App">
        <Board select={this.selectCountry}/>
        <p>{this.state.from}</p>
       </div>

  );
  }
}

export default App;
