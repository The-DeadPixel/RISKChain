import React, { Component } from 'react';

class Preview extends Component {
    constructor(props) {
        super(props);
        this.state ={
            type: props.type,
            name: props.name,
            path: "M803 361c1,-2 1,-3 2,-5 2,0 5,0 7,-1 0,2 0,3 0,4 -3,1 -6,1 -9,2z M802 349c-6,-11 -14,-7 -20,3 0,0 -1,0 -2,1 0,-1 0,-2 0,-3 -1,0 -3,0 -4,0 3,-7 3,-8 0,-16 -2,0 -3,1 -5,2 -1,-3 -2,-6 -3,-8 -5,1 -7,6 -13,8 0,2 0,3 1,5 -3,0 -6,1 -8,1 0,1 0,2 0,3 -3,0 -5,1 -8,1 1,-2 1,-3 1,-5 -3,0 -6,-1 -10,-1 -4,-4 -18,-13 -25,-14 0,-1 0,-2 0,-4 1,0 2,0 4,0 0,-5 0,-11 0,-16 -6,-1 -9,-1 -10,-7 -2,0 -5,0 -7,0 -2,-7 -7,-19 -7,-26 4,-1 7,-1 11,-2 0,-1 0,-2 0,-3 11,-4 5,-15 16,-18 2,-6 3,-7 7,-11 10,3 27,19 38,11 12,7 30,13 44,10 10,2 27,1 34,11 -1,1 -1,1 -4,0 1,1 2,3 3,4 1,0 2,1 4,1 -1,1 -1,2 -1,3 3,0 5,-1 14,0 0,1 0,1 0,2 -6,2 -9,3 -13,6 3,3 3,3 4,6 3,1 3,1 5,2 -1,1 -2,1 -3,2 2,0 3,1 4,1 1,2 1,3 1,5 -2,0 -2,0 -2,1 1,0 1,0 2,0 0,1 0,2 0,4 -1,0 -1,0 -2,0 7,14 -23,43 -36,41 0,1 0,3 0,5 -5,-1 -5,-4 -10,-5z M841 345c1,-8 1,-8 3,-12 1,0 2,0 2,0 0,-1 0,-2 0,-3 2,0 3,0 4,0 -2,8 -2,11 -9,15z ",
            register: props.register
        };
        console.log(props.register);
        Preview.selectThis = Preview.selectThis.bind(this);
        Preview.normalizeCountry = Preview.normalizeCountry.bind(this);
        this.chooseCountryForPreview = this.chooseCountryForPreview.bind(this);
        props.register(this.chooseCountryForPreview);

    }
    static selectThis(event) {
        console.log(event);
    }
    static normalizeCountry(dataPath) {
        let re = /M1[0-9\s]*c1/g;
        let result = dataPath.match(re);
        console.log(result);
    }
    chooseCountryForPreview(name, path) {
        this.setState({ name: name, path: path })
    }


    render() {
        //this.state.register(this.chooseCountryForPreview);

        //this.normalizeCountry(this.state.path);
        return (
            <div>
                <svg xmlns="http://www.w3.org/2000/svg"
                     width="100%" height="100%"
                     viewBox="0 0 1024 792"
                     onClick={Preview.selectThis}>
                <path className='outline' id="hilite" fill="green" strokeWidth="8" stroke="black" opacity="1" d={this.state.path}/>
                </svg>
            <p> {this.state.type +': '+ this.state.name} </p>
        </div>
        );
    }

}
export default Preview;
