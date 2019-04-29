pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

contract RISK {
    // Data Types

    enum ArmyType {Solider, Horse, Cannon, Wild}
    enum Status {Waiting, Placing, Attacking, Transferring, Dead}

    struct Player {
        string name;
        Status status;
        uint index;
        uint armyIncome;
        uint tempArmyIncome; // income that comes from cards played and only applies to that turn
        uint handSize;
        uint[] ownedRegions;
        mapping(uint => Card) hand;
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
        uint adjLength;
        uint[] adjRegions; //adjacency's that point to indexes of the Regions map
    }

    struct Card {
        uint continent;
        uint region;
        ArmyType aType;
    }

    uint tradeInVal;
    uint Seed;
    mapping(address => Player) Players;
    mapping(uint => Continent) Continents;
    mapping(uint => Region) Regions;
    Card[] DrawPile;
    uint[] listOwn;
    address[] PlayerAddrs;
    uint[] bonus = [3,7,2,5,5,2];
    uint[] numRegions = [6,12,4,7,9,4];
    uint[] numAdjList = [6,4,3,2,3,5,5,4,4,5,6,5,3,6,2,5,4,3,2,3,3,4,4,3,5,4,5,6,4,3,4,3,4,4,4,5,4,3,2,4,3,3];
    uint[] atckDie; uint[] defDie; // for storing dice roll values
    uint[] adjList = [1,2,3,4,5,10,0,5,10,26,0,3,4,0,3,0,1,2,0,1,2,28,39,7,10,13,16,27,6,10,13,12,9,15,17,11,8,11,14,17,29,6,7,0,1,26,
    27,8,9,13,14,15,7,13,21,6,7,11,12,15,16,9,12,8,11,13,16,17,6,13,15,27,8,9,15,19,20,18,20,21,18,19,21,19,20,12,
    23,24,25,28,22,25,32,22,24,25,26,27,22,23,24,27,24,27,28,1,10,24,25,26,6,10,16,22,24,26,5,34,30,9,29,34,35,36,
    32,36,41,31,35,36,37,34,35,37,23,29,30,33,35,30,33,34,36,37,30,31,32,35,32,33,35,39,40,38,40,41,5,38,39,41,39,40,31];

    // Constructor: setup string is a JSON that will populate the players and map owners
    /*
    * precondition: if names is defined, players and names MUST be the same length
    */
    function RISK(address[] players, string[] names, uint seed) public {
        uint totalOffset = 0;
        uint adjOffset = 0;
        uint initIncome = 50 - 5 * players.length; // the appropriate start of income depending on number of players

        if(seed == 0) {
            seed = uint(keccak256(block.blockhash(block.number-1), uint(keccak256(players)), now));
            Seed = seed;
        }
        else {
            Seed = seed;
        }
        for(uint pli = 0; pli < players.length; ++pli) {
            PlayerAddrs[pli] = players[pli];
            if(names.length != 0) {
                string memory currName = names[pli];
                Players[PlayerAddrs[pli]] = Player(currName, Status.Waiting, pli, initIncome, 0, 0, listOwn);
            }
            else
                Players[PlayerAddrs[pli]] = Player(string(abi.encodePacked("player", pli+1)), Status.Waiting, pli, initIncome, 0, 0, listOwn);
        }
        // set the first player turn status to placing
        Players[PlayerAddrs[0]].status = Status.Placing;

        tradeInVal = 4;
        for(uint i=0; i<= 6; ++i) {
            uint[] currRegInds;
            for(uint j=0; j < numRegions[i]; ++j) {
                uint offsetIndex = j+totalOffset;
                uint[] currAdjInds;
                currRegInds[j] = j+totalOffset; // totalOffset is the offset of the Regions map
                for(uint k=0; k < numAdjList[j+totalOffset]; ++k) {
                    currRegInds[k] = adjList[k+adjOffset];
                    adjOffset += 1; // cause Fuck it
                }
                Regions[j+totalOffset] = Region(PlayerAddrs[offsetIndex%PlayerAddrs.length],j+totalOffset,1,i,numAdjList[j+totalOffset],currAdjInds);
                Players[PlayerAddrs[offsetIndex%PlayerAddrs.length]].armyIncome -= 1; // this player has placed a troop
                Players[PlayerAddrs[offsetIndex%PlayerAddrs.length]].ownedRegions.push(j+totalOffset);
                // Initialize the region's card and add it to the draw pile (list) there are 42 cards, one for each region
                DrawPile[j+totalOffset+2] = Card(j+totalOffset,i,ArmyType(j+totalOffset%3));
            }
            totalOffset += numRegions[i]; // Increase the offset
            Continents[i] = Continent(0,bonus[i],currRegInds);
        }
        // Adding two wild cards to the end of the draw pile
        DrawPile.push(Card(69,69,ArmyType(4)));
        DrawPile.push(Card(69,69,ArmyType(4)));
    }

    // Public Phase Functions

    /** Drives all the requested armies placements as one block
    *   precondition: the length of newArmies must be the length of locations
    *   precondition: the player must be in the Placing status to place troops.
    **/
    function PlaceTroopsDriver(uint[] input) public returns(bool success) {
        success = false; // Only return true if the function has finished
        require(Players[msg.sender].status == Status.Placing, "You can't place armies right now!");
        for(uint i=0; i < input.length; i+=2) {
            if(!PlaceTroops(input[i], input[i+1]))
                return false;
        }
        Players[msg.sender].status = Status.Attacking;
        return true;
    }

    /** Drives all the requested cards to be played in one block
    *   precondition: input is the index's of the cards to be played
    *   precondition: the size of input must be 3
    *   precondition: the player must be in the Placing status to play cards.
    **/
    function playCards(uint[] input) public returns(bool success) {
        success = false;
        require(Players[msg.sender].status == Status.Placing, "You can't play cards right now!");
        require(input.length >= 3, "You have to play at least 3 cards!");
        require(input.length < 4, "You can only play 3 cards at a time!");
        require(Players[msg.sender].handSize >= input.length,
            "You are trying to play more cards then you own (might need a refresh)");
        // assign the cards to check the logic
        Card[] cards;
        for(uint currCard=0; currCard<=2; ++currCard)
            cards[currCard] = Players[msg.sender].hand[input[currCard]];
        if(checkCards(cards, msg.sender)) {
            Players[msg.sender].tempArmyIncome = tradeInVal;
            // now need to remove the cards from the hand
            for(uint i=0; i<=2; ++i) {
                // remove the index from the list
                for (uint j = input[i]; j<Players[msg.sender].handSize-1; j++)
                    Players[msg.sender].hand[j] = Players[msg.sender].hand[j+1];
                delete Players[msg.sender].hand[Players[msg.sender].handSize-1];
                Players[msg.sender].handSize--;
            }
            // after the sixth trade in value increases by 5
            if(tradeInVal >= 15) tradeInVal += 5;
            else tradeInVal += 2;
            return success = true;
        }
        else
            return success;
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
            if(Attack(input[i], input[i+1], input[i+2], Seed))
                victory = true;
        }
        // You can only ever have at most 6 cards at a time
        if(victory && Players[msg.sender].handSize <= 5 && DrawPile.length > 0)
            drawCards(msg.sender, Seed);
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
            if(!TrfArmies(input[i], input[i+1], input[i+2]))
                return false;
        }
        Players[msg.sender].status = Status.Waiting; // current players turn is now over.
        uint nextPlayer = Players[msg.sender].index + 1 % (PlayerAddrs.length - 1);
        Players[PlayerAddrs[nextPlayer]].status = Status.Placing; // sets the next player to the start of their turn (as Placing)
        return true;
    }

    // Internal Phase Functions

    function PlaceTroops(uint loc, uint newArmies) internal returns(bool success) {
        success = false; // Only return true if the function has finished
        require(Regions[loc].owner == msg.sender, "You do not own this region");
        require(newArmies > 0, "Must choose amount of armies to place");
        require(Players[msg.sender].armyIncome >= newArmies, "Not enough army surplus remaining to place these armies");

        Players[msg.sender].armyIncome -= newArmies;
        Regions[loc].numArmies += newArmies;
        return true;
    }

    function Attack(uint fromLoc, uint toLoc, uint numArmies) internal returns(bool victory) {
        victory = false;

        require(Regions[fromLoc].owner == msg.sender, "You can't attack from that region, you do not own it.");
        require(Regions[toLoc].owner != msg.sender, "Can only transfer troops during the transfer phase.");
        require(isAdjacent(Regions[fromLoc], toLoc), "You must attack regions that are adjacent.");
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
            //TODO impliment checking if defender is still alive and update it appropriatly
            Regions[toLoc].numArmies = numArmies; // remaining attacker armies are transfered to the toRegion
            Regions[toLoc].owner = msg.sender; // ownership is transfered to the attacker
            victory = true;
        }
        // defender wins
        else {
            Regions[toLoc].numArmies = Regions[toLoc].numArmies; // remaining defender's armies
            Regions[fromLoc].numArmies += numArmies; // if the attacker stops attacking then the armies are transfered back, else will transfer 0 since all armies are gone.
        }
        return victory;
    }

    function TrfArmies(uint numArmies, uint fromLoc, uint toLoc) internal returns(bool success) {
        success = false; // Only return true if the function has finished
        Region fromRegion = Regions[fromLoc];
        Region toRegion = Regions[toLoc];
        Player player = Players[msg.sender];

        require(fromRegion.owner == msg.sender && toRegion.owner == msg.sender, "You must own both regions to transfer");
        require(isAdjacent(fromRegion, toLoc), "You can only transfer to regions that are adjacent.");
        require(fromRegion.numArmies >= numArmies , "Trying to transfer with more armies that are in the region."); //TODO: make that error message better.
        require(fromRegion.numArmies - numArmies > 1, "One army must remain in the region transfering from.");

        fromRegion.numArmies -= numArmies;
        toRegion.numArmies += numArmies;
        return true;
    }

    // Internal Helper Functions

    /* Check the logic if the cards can reward an amount of army income */
    function checkCards(Card[] cards, address player) internal view returns(bool success) {
        success = false;
        bool wild = false;
        uint wildIndex;
        Card[] nonWilds;
        // check if any cards are wild
        for(uint i=0; i<=2; ++i) {
            if(cards[i].aType == ArmyType.Wild) {
                wildIndex = i;
                wild = true;
                break;
            }
            else nonWilds.push(cards[i]);
        }
        if(wild) {
            // 3 cards of the same armyType or 1 of each armyType
            if((nonWilds[0].aType == nonWilds[1].aType) || (nonWilds[0].aType != nonWilds[1].aType)) {
                success = true;
                CompareCardToRegion(cards, player);
                return success;
            }
            else
                return false;
        }
        else {
            // 3 cards of the same armyType or 1 of each armyType
            if((cards[0].aType == cards[1].aType && cards[0].aType == cards[2].aType) ||
                (cards[0].aType != cards[1].aType && cards[0].aType != cards[2].aType && cards[1].aType != cards[2].aType)) {
                success = true;
                CompareCardToRegion(cards, player);
                return success;
            }
            else
                return false;
        }
    }

    /* If one of the cards has a region that the player owns then place two extra troops in that region */
    function CompareCardToRegion(Card[] cards, address player) internal {
        for(uint i=0; i<=2; ++i) {
            if(Regions[cards[i].region].owner == player){
                Regions[cards[i].region].numArmies += 2;
                break;
            }
        }
    }

    /* Generates a random number from 0 to 5 based on the last block hash */
    function Rolldie() view internal returns (uint randomNumber) {
        return(uint(keccak256(block.blockhash(block.number-1), Seed ))%5);
    }

    /* Given a Region and a Location, will check if the Location exists in the adjacancy map */
    function isAdjacent(Region reg, uint dest) internal view returns(bool adjacent) {
        uint adjContinent = 0;
        uint adjRegion = 0;
        for(uint i = 0; i < reg.adjLength; ++i) {
            adjRegion = reg.adjRegions[i];
            if(adjRegion == dest)
                return true; // index is in the region adjRegions List
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

    function drawCards(address player) internal {
        uint value = uint(keccak256(block.blockhash(block.number-1), Seed))%DrawPile.length;
        if (value >= DrawPile.length) return;
        // Players[player].hand.push(DrawPile[value]); // adding the card to the current hand
        Players[player].hand[Players[player].handSize] = DrawPile[value];
        Players[player].handSize += 1;
        // remove the index from the list
        for (uint i = value; i<DrawPile.length-1; i++)
            DrawPile[i] = DrawPile[i+1];
        delete DrawPile[DrawPile.length-1];
        DrawPile.length--;
    }

    // Public View Functions

    function getCurrentPlayer() public view returns (address player) {
        for(uint i = 0; i < PlayerAddrs.length; ++i) {
            Status currStatus = Players[PlayerAddrs[i]].status;
            if(currStatus != Status.Waiting || currStatus != Status.Dead)
                return PlayerAddrs[i];
        }
        return 0;
    }

    //gets the opponents of the current players turn and returns them as a string in the form [player2, player3]
    function getCurrentPlayerOpponents(address currentPlayer) public view returns (string opponents) {
        opponents = "[";
        for(uint i=0; i <PlayerAddrs.length; ++i) {
            if (currentPlayer != PlayerAddrs[i]) {
                opponents = string(abi.encodePacked(opponents, PlayerAddrs[i]));
                if(i+1 < PlayerAddrs.length)
                    opponents = string(abi.encodePacked(opponents, ", "));
            }
        }
        opponents = "]";
        return opponents;
    }

    function getHand(address player) public view returns(string handJSON) {
        handJSON = "";
        Player playerHand = Players[player];
        for(uint i=0; i<playerHand.handSize;++i) {
            Card currCard = playerHand.hand[i];
            handJSON = string(abi.encodePacked(handJSON,i,":{"));
            handJSON = string(abi.encodePacked(handJSON,"continent: ", currCard.continent, ", "));
            handJSON = string(abi.encodePacked(handJSON,"country: ", currCard.region, ", "));
            handJSON = string(abi.encodePacked(handJSON,"type: ", uint(currCard.aType), "}"));
            if(i+1 < PlayerAddrs.length)
                handJSON = string(abi.encodePacked(handJSON, ", "));
        }
    }

    function getSizeOfHand(address player) view returns(uint size) {
        return Players[player].handSize;
    }

    function getBoard() public view returns (string boardState) {
        boardState = "";
        // board segment
        boardState = string(abi.encodePacked(boardState,"{", "board: {"));
        for(uint cont=0; cont<6; ++cont) {
            uint[] currRegions = Continents[cont].Regions;
            boardState = string(abi.encodePacked(boardState,cont,":{"));
            for(uint reg = 0; reg < currRegions.length; ++reg) {
                Region currReg = Regions[currRegions[reg]];
                boardState = string(abi.encodePacked(boardState,reg,":{","owner: ", currReg.owner, ",", "troops: ", currReg.numArmies));
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
        boardState = string(abi.encodePacked(boardState,"},"));
        boardState = string(abi.encodePacked(boardState,"config:{"));
        //        boardState = string(abi.encodePacked(boardState,"turn: ", currentPlayer, "phase: ", getStatusIntValue(currentPlayer)));
        boardState = string(abi.encodePacked(boardState,"turn: ", currentPlayer, "phase: ", uint(Players[currentPlayer].status)));
        boardState = string(abi.encodePacked(boardState, "opponents: ", getCurrentPlayerOpponents(currentPlayer)));
        boardState = string(abi.encodePacked(boardState,"},"));
        // cards segment
        boardState = string(abi.encodePacked(boardState,"card:{","hand:{"));
        boardState = string(abi.encodePacked(boardState,getHand(msg.sender), "}"));
        // closing bracket
        boardState = string(abi.encodePacked(boardState,"}"));
        return boardState;
    }
}
