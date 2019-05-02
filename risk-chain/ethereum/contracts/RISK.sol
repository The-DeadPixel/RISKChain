pragma solidity ^0.4.25;

contract RISK {
    // Data Types

    enum ArmyType {Solider, Horse, Cannon, Wild}
    enum Status {Waiting, Placing, Attacking, Transferring, Dead}

    struct Player {
        Status status;
        uint index;
        uint armyIncomeBonus;
        uint numOwnedRegions;
    }

    struct Continent {
        address owner;
        uint bonus;
        uint[] Regions;
    }

    struct Region {
        address owner;
        uint index; // index of the regions map (useful for checking adjacency's)
        uint numArmies;
        uint continent;
    }
    
    uint currPlayer;
    uint initIncome;
    uint totalOffset;
    uint Seed;
    mapping(address => Player) Players;
    mapping(uint => Continent) Continents;
    mapping(uint => Region) Regions;
    address[] PlayerAddrs;
    uint[] bonus = [3,7,2,5,5,2];
    uint[] numRegions = [6,12,4,7,9,4];
    uint[] atckDie;
    uint[] defDie; // for storing dice roll values
    /*
    * Constructor: setup string is a JSON that will populate the players and map owners
    * precondition: if names is defined, players and names MUST be the same length
    */
    function RISK(uint numPlayersIn, uint seed) public {
        initIncome = 50 - 5 * numPlayersIn;
        // if(seed == 0) {
        //     seed = uint(keccak256(block.blockhash(block.number-1), now));
        //     Seed = seed;
        // }
        // else 
        Seed = seed;
    }
    
    function() payable{}

    // Public Phase Functions
    
    function addPlayer(address player) public {
        PlayerAddrs.push(player);
        Players[player] = Player(Status.Waiting, currPlayer++, 0, 0);
        // set the first player turn status to placing
        if(PlayerAddrs.length-1 == 0)
            Players[player].status = Status.Placing;
    }
    
    function createContinents() {
        for(uint i=0; i< 6; ++i) { //for continents
            // empty array assigned to the size of the 
            uint[] memory regionSizeArray = new uint[](numRegions[i]);
            Continents[i] = Continent(0,bonus[i],regionSizeArray);
        }
    }
    
    function createRegions() {
        for(uint index=0; index<6; index++) {
        uint offsetIndex = 0;
        for(uint j=0; j < numRegions[index]; ++j) { //for each region in this continent
            offsetIndex = j+totalOffset;
            Regions[j+totalOffset] = Region(0,j,1,index);
        }
        totalOffset += numRegions[index]; // Increase the offset
        }
    }
    
    function assignPlayers() {
        for(uint i=0; i<42; i++) {
            Regions[i].owner = PlayerAddrs[i%PlayerAddrs.length];
            Players[Regions[i].owner].numOwnedRegions++;
        }
    }

    /* NOTE THIS IS GAMEPLAY WHISE STUPID UNFAIR FOR FIRST TURN */

    /** Drives all the requested armies placements as one block
    *   precondition: the length of newArmies must be the length of locations
    *   precondition: the player must be in the Placing status to place troops.
    **/
    function PlaceTroopsDriver(uint[] input) public returns(bool success) {
        success = false; // Only return true if the function has finished
        require(Players[msg.sender].status == Status.Placing, "You can't place armies right now!");
        // get the player income
        getPlayerIncome(msg.sender);
        for(uint i=0; i < input.length; i+=2) {
            PlaceTroops(input[i], input[i+1]);

        }
        Players[msg.sender].status = Status.Attacking;
        return true;
    }

    /** Drives all the requested attacks as one block
    *   precondition: the length of numArmies must be the length of toLoc & fromLoc
    *   precondition: the player must be in the Attacking status to attack.
    **/
    function AttackDriver(uint[] input) public returns(bool success) {
        success = false; // Only return true if the function has finished
        bool victory = false; // only true if the attacker won once, thus will draw a risk card
        require(Players[msg.sender].status == Status.Attacking, "You can't attack right now!");
        for(uint i=0; i < input.length; i+=3) {
            Attack(input[i], input[i+1], input[i+2]);
        }
        Players[msg.sender].status = Status.Transferring;
        return true;
    }

    /** Drives all the requested transfers as one block
    *   precondition: the length of numArmies must be the length of toLoc & fromLoc
    *   precondition: the player must be in the Transfering status to transfer.
    **/
    function TrfArmiesDriver(uint[] input) public returns(bool success) {
        success = false; // Only return true if the function has finished
        require(Players[msg.sender].status == Status.Transferring, "You can't transfer armies right now!");
        for(uint i=0; i < input.length; i+=3) {
            TrfArmies(input[i], input[i+1], input[i+2]);
        }
        Players[msg.sender].status = Status.Waiting; // current players turn is now over.
        uint nextPlayer = Players[msg.sender].index + 1 % (PlayerAddrs.length);
        Players[PlayerAddrs[nextPlayer]].status = Status.Placing; // sets the next player to the start of their turn (as Placing)
        return true;
    }

    // Internal Phase Functions

    function PlaceTroops(uint loc, uint newArmies) internal {
        require(Regions[loc].owner == msg.sender, "You do not own this region");
        require(newArmies > 0, "Must choose amount of armies to place");
        Regions[loc].numArmies += newArmies;
    }

    function Attack(uint fromLoc, uint toLoc, uint numArmies) internal {
        require(Regions[fromLoc].owner == msg.sender, "You can't attack from that region, you do not own it.");
        require(Regions[toLoc].owner != msg.sender, "Can only transfer troops during the transfer phase.");
        require(Regions[fromLoc].numArmies >= numArmies , "Trying to attack with more armies that are in the region."); //TODO: make that error message better.
        require(Regions[fromLoc].numArmies - numArmies > 1, "One army must remain in the region attacking from.");

        Regions[fromLoc].numArmies -= numArmies; // the armies are moved to attack
        uint atckDice; uint defDice;
        uint atckLosses; uint defLosses;
        bool attackerWins = false;

        while(numArmies > 0 && Regions[toLoc].numArmies > 0) {
            /* Assign dice to the attacker and defender */
            // max 3 attacker die
            if(numArmies >= 3)
                atckDice = 3;
            else if(numArmies == 2)
                atckDice = 2;
            else atckDice = 1;
            // max 2 defender die
            if(Regions[toLoc].numArmies >= 2)
                defDice = 2;
            else defDice = 1;

            /* Calculate random dice rolls and sort them from lowest to highest using quickSort*/
            for (uint i = 0; i < atckDice; i++)
                atckDie[i] = Rolldie();
            atckDie = sort(atckDie,atckDice);

            for (uint j = 0; i < defDice; j++)
                defDie[i] = Rolldie();
            defDie = sort(defDie,defDice);

            /* Compare the rolls and calculate losses */
            if(atckDice > defDice)
                (atckLosses, defLosses) = atckFavoredCompare(atckDice, defDice);
            else if(defDice < atckDice)
                (atckLosses, defLosses) = EvenCompare(atckDice, defDice);
            else
                (atckLosses, defLosses) = defFavoredCompare();
            numArmies -= atckLosses;
            Regions[toLoc].numArmies -= defLosses;

            /* Finally check if the Defender army is depleted, if so then the attacker wins*/
            if(Regions[toLoc].numArmies == 0)
                attackerWins = true;
        }
        if(attackerWins) {
            address def = Regions[toLoc].owner;
            if(Players[def].numOwnedRegions-- <= 0)
                Players[def].status = Status.Dead;
            Regions[toLoc].numArmies = numArmies; // remaining attacker armies are transfered to the toRegion
            Players[msg.sender].numOwnedRegions++;
            checkContinentOwnership(msg.sender, def, toLoc); // check if the attacker now owns the continent, and if the defender owned it, it doesn't anymore
            Regions[toLoc].owner = msg.sender; // ownership is transfered to the attacker
        }
    }

    function TrfArmies(uint numArmies, uint fromLoc, uint toLoc) internal {
        Region fromRegion = Regions[fromLoc];
        Region toRegion = Regions[toLoc];
        Player player = Players[msg.sender];

        require(fromRegion.owner == msg.sender && toRegion.owner == msg.sender, "You must own both regions to transfer");
        require(fromRegion.numArmies >= numArmies , "Trying to transfer with more armies that are in the region."); //TODO: make that error message better. might wanna remove
        require(fromRegion.numArmies - numArmies >= 1, "One army must remain in the region transferring from.");

        Regions[fromLoc].numArmies -= numArmies;
        Regions[toLoc].numArmies += numArmies;
    }

    // Internal Helper Functions

    function checkContinentOwnership(address attacker, address defender, uint region) internal { //Attacker Won to get here
        if(Continents[Regions[region].continent].owner == defender) { //defender did own and is losing
            Continents[Regions[region].continent].owner = 0;
            Players[defender].armyIncomeBonus -= Continents[Regions[region].continent].bonus;
        }
        uint[] currReg = Continents[Regions[region].continent].Regions;
        for(uint i=0; i<currReg.length; ++i)
            if(Regions[currReg[i]].owner != attacker)
                return;
        // if this point hits then all the regions in the continent are owned by the attacker
        Continents[Regions[region].continent].owner = attacker;
        Players[defender].armyIncomeBonus += Continents[Regions[region].continent].bonus;
    }

    /* Generates a random number from 0 to 5 based on the last block hash */
    function Rolldie() view internal returns (uint randomNumber) {
        return(uint(keccak256(block.blockhash(block.number-1), Seed ))%6);
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
    

    /* Get the income for a given player, also if there is bonuses to be applied then apply them and assign it to the map*/
    function getPlayerIncome(address player) public returns(uint income) {
        Player currPlayer = Players[player];
        income = 0; // this is important to keep the initial income left over from placement
        if(currPlayer.armyIncomeBonus > 0) {
            income += currPlayer.armyIncomeBonus;
        }
        // how you calculate income based off of controlled regions
        income += currPlayer.numOwnedRegions/3; // this will truncate down to a int
        return income;
    }
    
    function addressToString(address _addr) public pure returns(string) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
    
    function uintToString(uint i) internal pure returns (string memory uintAsString) {
        if (i == 0) {
            return "0";
        }
        uint j = i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    /* Get the player that currently has the placing, attacking, or transferring status*/
    function getCurrentPlayer() public view returns (address player) {
        for(uint i = 0; i < PlayerAddrs.length; ++i) {
            Status currStatus = Players[PlayerAddrs[i]].status;
            if(currStatus != Status.Waiting || currStatus != Status.Dead)
                return PlayerAddrs[i];
        }
        return 0;
    }

    /* Gets the opponents of the current players turn and returns them as a string in the form [player2, player3] */
    function getCurrentPlayerOpponents(address currentPlayer) public view returns (string opponents) {
        opponents = "[";
        for(uint i=0; i <PlayerAddrs.length; ++i) {
            if (currentPlayer != PlayerAddrs[i]) {
                opponents = string(abi.encodePacked(opponents, '"',addressToString(PlayerAddrs[i]),'"'));
                if(i+1 < PlayerAddrs.length)
                    opponents = string(abi.encodePacked(opponents, ", ","","",""));
            }
        }
        opponents = string(abi.encodePacked(opponents,"]","",""));
        return opponents;
    }
    
    /* Gets the opponents of the current players turn and returns them as a string in the form [player2, player3] */
    function getAllPlayers() public view returns (string opponents) {
        opponents = "[";
        for(uint i=0; i <PlayerAddrs.length; ++i) {
            opponents = string(abi.encodePacked(opponents, addressToString(PlayerAddrs[i]),"","",""));
            if(i+1 < PlayerAddrs.length)
                opponents = string(abi.encodePacked(opponents, ", ","","",""));
        }
        opponents = string(abi.encodePacked(opponents,"]","",""));
        return opponents;
    }
    
    /* Returns the entire game state in JSON formatting, called by the client to update the state */
    function getGameState() public view returns (string boardState) {
        boardState = "";
        // board segment
        boardState = string(abi.encodePacked(boardState,"{", '"board": {',"",""));
        for(uint cont=0; cont<6; ++cont) {
            uint[] currRegions = Continents[cont].Regions;
            boardState = string(abi.encodePacked(boardState,'"',uintToString(cont),'":{'));
            for(uint reg = 0; reg < currRegions.length; ++reg) {
                Region currReg = Regions[currRegions[reg]];
                boardState = string(abi.encodePacked(boardState,uintToString(reg),":{",'"owner":"', addressToString(currReg.owner), '",', '"troops":"', uintToString(currReg.numArmies),'"'));
                if(reg+1 < currRegions.length)
                    boardState = string(abi.encodePacked(boardState,"},"));
                else
                    boardState = string(abi.encodePacked(boardState,"}"));
            }
            if(cont == 5)
                boardState = string(abi.encodePacked(boardState,"}"));
            else
                boardState = string(abi.encodePacked(boardState,"},"));
        }
        address currentPlayer = getCurrentPlayer();
        // config segment
        boardState = string(abi.encodePacked(boardState,"}", '"config":{'));
        boardState = string(abi.encodePacked(boardState,'"turn":', addressToString(currentPlayer), ',"phase":"', uintToString(uint(Players[currentPlayer].status)),'"'));
        boardState = string(abi.encodePacked(boardState, ',"opponents":', getCurrentPlayerOpponents(currentPlayer)));
        boardState = string(abi.encodePacked(boardState,"}}"));
        return boardState;
    }
}
