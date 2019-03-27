import React, { Component } from 'react';
import risk from '../resources/risk.svg';
import path from '../resources/path.svg';

class Map extends Component {
    render() {
        return (
            <div>
                <img src={risk} alt={'Map of world'} />
            </div>
        );
    }
}

export default Map;
