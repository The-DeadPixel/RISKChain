import React, { Component } from 'react';
import risk from '../resources/risk.svg';
import path from '../resources/path.svg';

class Map extends Component {
    render() {
        //var data = ('../resources/path.svg');
        console.log({path});
        return (
           <img src={('../resources/map.svg')} />
        );
    }
}

export default Map;
