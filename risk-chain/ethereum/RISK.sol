pragma solidity ^0.4.25;

contract RISK {
    // Data Types
        
    struct Player {
        string name;
        uint status; // int that defines player alive/dead, current turn, and current phase. TODO: exact implimentation TBD
        uint index;
        uint armyIncome;
    }
    
    struct Continent {
        address owner;
        uint bonus;
        mapping(uint => Region) Regions;
    }
    
    struct Region {
        address owner;
        uint numArmies;
        uint coninent;
        mapping(uint => uint) adjRegions; // might be better to use a list instead (tbd)
    }
    
    //tuple for finding a region within a continent struct
    struct Location {
        uint continent;
        uint region;
    }
    
    mapping(address => Player) Players;
    mapping(uint => Continent) Continents;
    // Constructor
    
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
    
    function Attack(uint numArmies, Location fromLoc, Location toLoc) internal returns(bool success) {
        Region fromRegion = Continents[fromLoc.continent].Regions[fromLoc.region];
        Region toRegion = Continents[toLoc.continent].Regions[toLoc.region];
        Player player = Players[msg.sender];
        
        // Needs to have a require for checking correct turn phase
        require(fromRegion.owner == msg.sender, "You can't attack from that region, you do not own it.");
        require(toRegion.owner != msg.sender, "Can only transfer troops during the transfer phase.");
        require(fromRegion.adjRegions[toLoc.region] != 0, "You must attack regions that are adjacent.");
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
        require(fromRegion.adjRegions[toLoc.region] != 0, "You can only transfer to regions that are adjacent.");
        require(fromRegion.numArmies >= numArmies , "Trying to transfer with more armies that are in the region."); //TODO: make that error message better.
        require(fromRegion.numArmies - numArmies > 1, "One army must remain in the region transfering from.");
        
        fromRegion.numArmies -= numArmies;
        toRegion.numArmies += numArmies;
        return true;
    }
    
    // Helper Functions
    
    /* Generates a random number from 0 to 5 based on the last block hash */
    function randomGen(uint seed) constant returns (uint randomNumber) {
        return(uint(keccak256(block.blockhash(block.number-1), seed ))%5);
    }
}
