import React, { Component } from 'react';

class Controller extends Component {
    constructor(props) {
        super(props);
        this.setType = this.setType.bind(this);
        this.state ={
            type: props.type,
            phase: props.phase,
            selectTo: props.selectTo,
            selectFrom: props.selectFrom
        }
    }

    setType(){
        console.log(this.state.type);
        if(!this.state.type) {
            this.state.selectTo();

        }else {
            this.state.selectFrom();
        }
        this.setState({type: !this.state.type }, () => {
            console.log(this.state);
        })
    }
render() {
        return (
            <div>
                <button onClick={this.setType}>{this.state.type? 'Choose Source': 'Choose Destination' }</button>
            </div>
        );
    }

}
export default Controller;
