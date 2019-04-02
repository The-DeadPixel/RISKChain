pragma solidity ^0.4.25;

contract RISK {
    // Data Types

    enum armyType {Solider, Horse, Cannon}

    struct Player {
        string name;
        uint status; // int that defines player alive/dead, current turn, and current phase. TODO: exact implimentation TBD
        uint index;
        uint armyIncome;
    }
    struct Continent {
        address owner;
        uint bonus;
        uint[] Regions;
    }

    struct Region {
        address owner;
        uint index; // index of the regions map (useful for checking adjacencies)
        uint numArmies;
        uint continent;
        uint adjLength;
        uint[] adjRegions; //adjacencies that point to indexes of the Regions map
    }

    //TODO: MAKE TOKEN CONTRACT FOR RISK CARD DRAW PILE AND CARDS

    mapping(address => Player) Players;
    mapping(uint => Continent) Continents;
    mapping(uint => Region) Regions;
    uint[] bonus = [3,7,2,5,5,2];
    uint[] numRegions = [6,12,4,7,9,4];
    uint[] numAdjList = [6,4,3,2,3,5,5,4,4,5,6,5,3,6,2,5,4,3,2,3,3,4,4,3,5,4,5,6,4,3,4,3,4,4,4,5,4,3,2,4,3,3];
    uint[] atckDie; uint[] defDie; // for storing dice roll values
    uint[] adjList = [1,2,3,4,5,10,0,5,10,26,0,3,4,0,3,0,1,2,0,1,2,28,39,7,10,13,16,27,6,10,13,12,9,15,17,11,8,11,14,17,29,6,7,0,1,26,
    27,8,9,13,14,15,7,13,21,6,7,11,12,15,16,9,12,8,11,13,16,17,6,13,15,27,8,9,15,19,20,18,20,21,18,19,21,19,20,12,
    23,24,25,28,22,25,32,22,24,25,26,27,22,23,24,27,24,27,28,1,10,24,25,26,6,10,16,22,24,26,5,34,30,9,29,34,35,36,
    32,36,41,31,35,36,37,34,35,37,23,29,30,33,35,30,33,34,36,37,30,31,32,35,32,33,35,39,40,38,40,41,5,38,39,41,39,40,31];

    // Constructor

    function RISK() public {
        //TODO populate the Player map struct
        uint totalOffset = 0;
        uint adjOffset = 0;
        for(uint i=0; i<= 6; ++i) {
            uint[] currRegInds;
            for(uint j=0; j < numRegions[i]; ++j) {
                uint[] currAdjInds;
                currRegInds[j] = j+totalOffset; // totalOffset is the offset of the Regions map
                for(uint k=0; k < numAdjList[j+totalOffset]; ++k) {
                    currRegInds[k] = adjList[k+adjOffset];
                    adjOffset += 1; // cause Fuck it
                }
                Regions[j+totalOffset] = Region(0,j+totalOffset,0,i,numAdjList[j+totalOffset],currAdjInds);
            }
            totalOffset += numRegions[i]; // Increase the offset
            Continents[i] = Continent(0,bonus[i],currRegInds);
        }
    }

    // Functions

    function PlaceTroops(uint newArmies, Location loc) internal returns(bool success) {
        Region region = Continents[loc.continent].Regions[loc.region];
        Player player = Players[msg.sender];

        // Needs to have a require for checking correct turn phase
        require(region.owner == msg.sender, "You do not own this region");
        require(newArmies > 0, "Must choose amount of armies to place");
        require(player.armyIncome >= newArmies, "Not enough army surplus remaining to place these armies");

        player.armyIncome -= newArmies;
        region.numArmies += newArmies;
        return true;
    }

    function Attack(Location fromLoc, Location toLoc, uint numArmies, uint seed) internal returns(bool success) {
        Region fromRegion = Continents[fromLoc.continent].Regions[fromLoc.region];
        Region toRegion = Continents[toLoc.continent].Regions[toLoc.region];
        Player attacker = Players[msg.sender];
        Player defender = Players[toRegion.owner];

        // Needs to have a require for checking correct turn phase
        require(fromRegion.owner == msg.sender, "You can't attack from that region, you do not own it.");
        require(toRegion.owner != msg.sender, "Can only transfer troops during the transfer phase.");
        require(isAdjacent(fromRegion, toLoc), "You must attack regions that are adjacent.");
        require(fromRegion.numArmies >= numArmies , "Trying to attack with more armies that are in the region."); //TODO: make that error message better.
        require(fromRegion.numArmies - numArmies > 1, "One army must remain in the region attacking from.");

        fromRegion.numArmies -= numArmies; // the armies are moved to attack
        uint atckArmy = numArmies;
        uint defArmy = toRegion.numArmies;
        uint atckDice; uint defDice;
        uint atckLosses; uint defLosses;
        bool attackerWins = false;

        while(atckArmy > 0 && defArmy > 0) {
            /* Assign dice to the attacker and defender */
            // max 3 attacker die
            if(atckArmy >= 3)
                atckDice = 3;
            else if(atckArmy == 2)
                atckDice = 2;
            else atckDice = 1;
            // max 2 defender die
            if(defArmy >= 2)
                defDice = 2;
            else defDice = 1;

            /* Calculate random dice rolls and sort them from lowest to highest using quickSort*/
            for (uint i = 0; i < atckDice; i++)
                atckDie[i] = Rolldie(seed);
            atckDie = sort(atckDie,atckDice);

            for (uint j = 0; i < defDice; j++)
                defDie[i] = Rolldie(seed);
            defDie = sort(defDie,defDice);

            /* Compare the rolls and calculate losses */
            if(atckDice > defDice)
                (atckLosses, defLosses) = atckFavoredCompare(atckDice, defDice);
            else if(defDice < atckDice)
                (atckLosses, defLosses) = EvenCompare(atckDice, defDice);
            else
                (atckLosses, defLosses) = defFavoredCompare();
            atckArmy -= atckLosses;
            defArmy -= defLosses;

            /* Finally check if the Defender army is depleted, if so then the attacker wins*/
            if(defArmy == 0)
                attackerWins = true;
        }
        if(attackerWins) {
            toRegion.numArmies = atckArmy; // remaining attacker armies are transfered to the toRegion
            toRegion.owner = msg.sender; // ownership is transfered to the attacker
        }
        // defender wins
        else {
            toRegion.numArmies = defArmy; // remaining defender's armies
            fromRegion.numArmies += atckArmy; // if the attacker stops attacking then the armies are transfered back, else will transfer 0 since all armies are gone.
        }
        return true;
    }

    function TrfTroops(uint numArmies, Location fromLoc, Location toLoc) internal returns(bool success) {
        Region fromRegion = Continents[fromLoc.continent].Regions[fromLoc.region];
        Region toRegion = Continents[toLoc.continent].Regions[toLoc.region];
        Player player = Players[msg.sender];

        // Needs to have a require for checking correct turn phase
        require(fromRegion.owner == msg.sender && toRegion.owner == msg.sender, "You must own both regions to transfer");
        require(isAdjacent(fromRegion, toLoc), "You can only transfer to regions that are adjacent.");
        require(fromRegion.numArmies >= numArmies , "Trying to transfer with more armies that are in the region."); //TODO: make that error message better.
        require(fromRegion.numArmies - numArmies > 1, "One army must remain in the region transfering from.");

        fromRegion.numArmies -= numArmies;
        toRegion.numArmies += numArmies;
        return true;
    }

    // Internal Helper Functions

    /* Generates a random number from 0 to 5 based on the last block hash */
    function Rolldie(uint seed) view internal returns (uint randomNumber) {
        return(uint(keccak256(block.blockhash(block.number-1), seed ))%5);
    }

    /* Given a Region and a Location, will check if the Location exists in the adjacancy map */
    function isAdjacent(Region region, Location dest) internal view returns(bool adjacent) {
        uint adjContinent = 0;
        uint adjRegion = 0;
        for(uint i = 0; i < adjLength; ++i) {
            adjContinent = region.adjRegions[i].continent;
            adjRegion = region.adjRegions[i].region;
            // Found null padding (Location(6,0)) at end of list
            if(adjContinent == 6 && adjRegion == 0)
                return false;
            if(adjContinent == dest.continent && adjRegion == dest.region)
                return true; // Location is in the region adjRegions List
        }
        return false; // got through the whole list and did not find the dest Location
    }

    /** Calculates roll outcome, optimized comparrison for when the attacker has more die then the defender
    *   precondition: the attacker must have more die than the defenders.
    *   precondition: the roll arrays must be sorted min-max.
    **/
    function atckFavoredCompare(uint atckDice, uint defDice) internal view returns (uint atckLosses, uint defLosses) {
        (atckLosses=0, defLosses=0); // init output
        uint defRoll = 0; uint atckRoll = 0;
        for(uint i=defDice-1; i >= 0; --i) {
            defRoll = defDie[i];
            atckRoll = atckDie[i+1]; // NOTE: this is a safe statement since the precondition of this function
            // NOTE: Defender wins ties
            if(defRoll >= atckRoll)
                atckLosses += 1;
            else
                defLosses += 1;
        }
        return (atckLosses, defLosses);
    }

    /** Calculates roll outcome, optimized comparrison for when the attacker and defender have the same number of die
    *   precondition: the attacker and defender must have the same amount of die.
    *   precondition: the roll arrays must be sorted min-max.
    **/
    function EvenCompare(uint atckDice, uint defDice) internal view returns (uint atckLosses, uint defLosses) {
        (atckLosses=0, defLosses=0); // init output
        uint defRoll = 0; uint atckRoll = 0;
        for(uint i=defDice-1; i >= 0; --i) {
            defRoll = defDie[i];
            atckRoll = atckDie[i+1]; // NOTE: this is a safe statement since the precondition of this function
            // NOTE: Defender wins ties
            if(defRoll >= atckRoll)
                atckLosses += 1;
            else
                defLosses += 1;
        }
        return (atckLosses, defLosses);
    }

    /** Calculates roll outcome, optimized comparrison for when the defender has more die then the attacker
    *   precondition: the defender must have more die than the attackers.
    *   precondition: the roll arrays must be sorted min-max.
    **/
    function defFavoredCompare() internal view returns (uint atckLosses, uint defLosses) {
        (atckLosses=0, defLosses=0); // init output
        /* Only one condition where there is one attacker dice, and two defender die */
        // NOTE: Defender wins ties
        if(defDie[1] >= atckDie[0])
            atckLosses += 1;
        else
            defLosses += 1;
        return (atckLosses, defLosses);
    }

    /* Takes an array and calls Quick Sort to sort from smallest to largest values */
    function sort(uint[] data, uint arraySize) public pure returns(uint[]) {
        quickSort(data, int(0), int(arraySize - 1));
        return data;
    }

    /* Uses Quick Sort algorithm, which sorts from smallest to largest values */
    function quickSort(uint[] memory arr, int left, int right) internal pure {
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    // Public View Functions

    function getBoard() public view returns (string boardState) { // NOTE: use s =  string(abi.encodePacked("", "", "", "", "")); to concat the strings
        string memory finalOut = "";
        for(uint i=0; i <= 6 ;++i) {
            string memory round = "";
            //TODO FINISH THE view function
            for(uint j=0; j < numRegions[i]; ++j) {

            }
        }
    }
}
