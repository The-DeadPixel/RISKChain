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
        Region[] Regions;
    }

    struct Region {
        address owner;
        uint numArmies;
        uint continent;
        Location[] adjRegions; // might be better to use a list instead (tbd)
    }

    //tuple for finding a region within a continent struct
    struct Location {
        uint continent;
        uint region;
    }

    //TODO: MAKE TOKEN CONTRACT FOR RISK CARD DRAW PILE AND CARDS
    struct card {
        Location loc;
        armyType val;
    }

    mapping(address => Player) Players;
    mapping(uint => Continent) Continents;

    uint[] bonus = [3,7,2,5,5,2];
    uint[] numRegions = [6,12,4,7,9,4];
    Location[] adjancies = [Location(0,1), Location(0,2), Location(0,3), Location(0,4), Location(0,5), Location(1,4),
                        Location(0,0), Location(0,5), Location(1,4), Location(3,4), Location(6,0), Location(6,0),
                        Location(0,0), Location(0,3), Location(0,4), Location(6,0), Location(6,0), Location(6,0),
                        Location(0,0), Location(0,3), Location(6,0), Location(6,0), Location(6,0), Location(6,0),
                        Location(0,0), Location(0,1), Location(0,2), Location(6,0), Location(6,0), Location(6,0),
                        Location(0,0), Location(0,1), Location(0,2), Location(3,6), Location(5,1), Location(6,0),
                        Location(1,1), Location(1,4), Location(1,7), Location(1,10), Location(3,5), Location(6,0),
                        Location(1,0), Location(1,4), Location(1,7), Location(1,6), Location(6,0), Location(6,0),
                        Location(1,3), Location(1,9), Location(1,11), Location(1,5), Location(6,0), Location(6,0),
                        Location(1,2), Location(1,5), Location(1,8), Location(1,11), Location(4,0), Location(6,0),
                        Location(1,0), Location(1,1), Location(0,0), Location(0,1), Location(3,4), Location(3,5),
                        Location(1,2), Location(1,3), Location(1,7), Location(1,8), Location(1,9), Location(6,0),
                        Location(1,1), Location(1,7), Location(2,3), Location(6,0), Location(6,0), Location(6,0),
                        Location(1,0), Location(1,1), Location(1,5), Location(1,6), Location(1,9), Location(1,10),
                        Location(1,3), Location(1,6), Location(6,0), Location(6,0), Location(6,0), Location(6,0),
                        Location(1,2), Location(1,5), Location(1,7), Location(1,10), Location(1,11), Location(6,0),
                        Location(1,0), Location(1,7), Location(1,9), Location(3,5), Location(6,0), Location(6,0),
                        Location(1,2), Location(1,3), Location(1,9), Location(6,0), Location(6,0), Location(6,0),
                        Location(2,1), Location(2,2), Location(6,0), Location(6,0), Location(6,0), Location(6,0),
                        Location(2,0), Location(2,2), Location(2,3), Location(6,0), Location(6,0), Location(6,0),
                        Location(2,0), Location(2,1), Location(2,3), Location(6,0), Location(6,0), Location(6,0),
                        Location(2,1), Location(2,2), Location(1,6), Location(6,0), Location(6,0), Location(6,0),
                        Location(3,1), Location(3,2), Location(3,3), Location(3,6), Location(6,0), Location(6,0),
                        Location(3,0), Location(3,3), Location(4,3), Location(6,0), Location(6,0), Location(6,0),
                        Location(3,0), Location(3,2), Location(3,3), Location(3,4), Location(3,5), Location(6,0),
                        Location(3,0), Location(3,1), Location(3,2), Location(3,5), Location(6,0), Location(6,0),
                        Location(3,2), Location(3,5), Location(3,6), Location(0,1), Location(1,4), Location(6,0),
                        Location(3,2), Location(3,3), Location(3,4), Location(1,0), Location(1,4), Location(1,10),
                        Location(3,0), Location(3,2), Location(3,4), Location(0,5), Location(6,0), Location(6,0),
                        Location(4,5), Location(4,1), Location(1,3), Location(6,0), Location(6,0), Location(6,0),
                        Location(4,0), Location(4,5), Location(4,6), Location(4,7), Location(6,0), Location(6,0),
                        Location(4,3), Location(4,7), Location(5,3), Location(6,0), Location(6,0), Location(6,0),
                        Location(4,2), Location(4,6), Location(4,7), Location(4,8), Location(6,0), Location(6,0),
                        Location(4,5), Location(4,6), Location(4,8), Location(3,1), Location(6,0), Location(6,0),
                        Location(4,0), Location(4,1), Location(4,4), Location(4,6), Location(6,0), Location(6,0),
                        Location(4,1), Location(4,4), Location(4,5), Location(4,7), Location(4,8), Location(6,0),
                        Location(4,1), Location(4,2), Location(4,3), Location(4,6), Location(6,0), Location(6,0),
                        Location(4,3), Location(4,4), Location(4,6), Location(6,0), Location(6,0), Location(6,0),
                        Location(5,1), Location(5,2), Location(6,0), Location(6,0), Location(6,0), Location(6,0),
                        Location(5,0), Location(5,2), Location(5,3), Location(0,5), Location(6,0), Location(6,0),
                        Location(5,0), Location(5,1), Location(5,3), Location(6,0), Location(6,0), Location(6,0),
                        Location(5,1), Location(5,2), Location(4,2), Location(6,0), Location(6,0), Location(6,0)];

    // Constructor

    function RISK() public {
        //TODO populate the Player map struct
        for(uint i = 0; i <= 6; ++i) {
            Region[] currReg;
            for(uint j = 0; j < numRegions[i]; ++j) {
                Location[] adjRegions;
                for(uint k=j*6; k < 6; ++k)
                    adjRegions[k] = adjancies[k];
                currReg[i] = Region(0,0,i,adjRegions);
            }
            Continents[i] = Continent(0,bonus[i],currReg);
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

    function Attack(uint numArmies, Location fromLoc, Location toLoc, uint seed) internal returns(bool success) {
        Region fromRegion = Continents[fromLoc.continent].Regions[fromLoc.region];
        Region toRegion = Continents[toLoc.continent].Regions[toLoc.region];
        Player player = Players[msg.sender];

        // Needs to have a require for checking correct turn phase
        require(fromRegion.owner == msg.sender, "You can't attack from that region, you do not own it.");
        require(toRegion.owner != msg.sender, "Can only transfer troops during the transfer phase.");
        require(fromRegion.adjRegions[toLoc.region] != 0, "You must attack regions that are adjacent."); //TODO: fix the type conversion
        require(fromRegion.numArmies >= numArmies , "Trying to attack with more armies that are in the region."); //TODO: make that error message better.
        require(fromRegion.numArmies - numArmies > 1, "One army must remain in the region attacking from.");

        fromRegion.numArmies -= numArmies; // the armies are moved to attack
        uint attackerArmies = numArmies;
        uint defenderArmies = toRegion.numArmies;
        bool attackerWins = false;
        while(attackerArmies > 0 && defenderArmies > 0) {
            // TODO: Impliment the dice rolling seed as well as the random generator for the dice rolling

        }

        if(attackerWins) {
            toRegion.numArmies = attackerArmies; // remaining attacker armies are transfered to the toRegion
            toRegion.owner = msg.sender; // ownership is transfered to the attacker
        }
        // defender wins
        else {
            toRegion.numArmies = defenderArmies; // remaining defender's armies
            fromRegion.numArmies += attackerArmies; // if the attacker stops attacking then the armies are transfered back, else will transfer 0 since all armies are gone.
        }
        return true;
    }

    function TrfTroops(uint numArmies, Location fromLoc, Location toLoc) internal returns(bool success) {
        Region fromRegion = Continents[fromLoc.continent].Regions[fromLoc.region];
        Region toRegion = Continents[toLoc.continent].Regions[toLoc.region];
        Player player = Players[msg.sender];

        // Needs to have a require for checking correct turn phase
        require(fromRegion.owner == msg.sender && toRegion.owner == msg.sender, "You must own both regions to transfer");
        require(fromRegion.adjRegions[toLoc.region] != 0, "You can only transfer to regions that are adjacent."); //TODO: fix the type conversion
        require(fromRegion.numArmies >= numArmies , "Trying to transfer with more armies that are in the region."); //TODO: make that error message better.
        require(fromRegion.numArmies - numArmies > 1, "One army must remain in the region transfering from.");

        fromRegion.numArmies -= numArmies;
        toRegion.numArmies += numArmies;
        return true;
    }

    // Helper Functions

    /* Generates a random number from 0 to 5 based on the last block hash */
    function Rolldie(uint seed) constant internal returns (uint randomNumber) {
        return(uint(keccak256(block.blockhash(block.number-1), seed ))%5);
    }
        
    // View Functions
    
    function getBoard() public view returns (string boardState) { //NOTE: use s =  string(abi.encodePacked("", "", "", "", "")); to concat the strings
        string memory finalOut = "";
        for(uint i=0; i <= 6 ;++i) {
            string memory round = "";
            //TODO FINISH THE view function
            for(uint j=0; j < numRegions[i]; ++j) {
                
            }
        }
    }
}
