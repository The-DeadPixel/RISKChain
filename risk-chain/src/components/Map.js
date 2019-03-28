import React, { Component } from 'react';
import Risk from '../resources/risk.svg';

import path from '../resources/path.svg';
import map from '../resources/map.svg';

class Map extends Component {
    constructor(props) {
        super(props);
        this.initMap = this.initMap.bind(this);
    }
    initMap( event ) {
        console.log(event)
    }
    render() {
        console.log({map});
        console.log(require('../resources/path.svg'));
        /**
         *
         *
         *
         * <div>
         <img src={map} alt={'Map of world'} onLoad={this.initMap}/>
         </div>
         *
         */
        return (<div>
                <img src={map} alt={'Map of world'} onLoad={this.initMap}/>
            </div>
        );
    }
}

export default Map;
