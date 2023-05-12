// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract RSVP {
    event NewEventCreated(
        bytes32 eventId,
        address creator,
        uint256 eventTime,
        uint256 capacity,
        uint256 depositAmount,
        string eventDataHash
    );

    event NewRSVP(bytes32 eventId, address attendee);

    event AttendeeConfirmed(bytes32 eventId, address attendee);

    event DepositsPaidOut(bytes32 eventId);

    struct Event {
        bytes32 eventId;
        string eventDataHash;
        address eventOwner;
        uint256 eventTime;
        uint256 depositAmount;
        uint256 maxCapacity;
        address[] confirmedRSVPs;
        address[] claimedRSVPs;
        bool paidOut;
    }

    mapping(bytes32 => Event) public events;

    function createNewEvent(
        uint256 eventTime,
        uint256 depositAmount,
        uint256 maxCapacity,
        string calldata eventDataHash
    ) external {
        // generate an event ID based on other variables to create a hash
        bytes32 eventId = keccak256(
            abi.encodePacked(
                msg.sender,
                address(this),
                eventTime,
                depositAmount,
                maxCapacity
            )
        );

        address[] memory confirmedRSVPs;
        address[] memory claimedRSVPs;

        // create a new Event struct and add it to the events mapping
        events[eventId] = Event(
            eventId,
            eventDataHash,
            msg.sender,
            eventTime,
            depositAmount,
            maxCapacity,
            confirmedRSVPs,
            claimedRSVPs,
            false
        );

        emit NewEventCreated(
            eventId,
            msg.sender,
            eventTime,
            maxCapacity,
            depositAmount,
            eventDataHash
        );
    }

    function createNewRSVP(bytes32 eventId) external payable {
        // look up the event
        Event storage myEvent = events[eventId];

        // transfer the deposit to our contract and require that enough ETH was sent
        require(msg.value == myEvent.depositAmount, "INSUFFICIENT FUNDS");

        // require that the event hasn't already happened
        require(block.timestamp <= myEvent.eventTime, "ALREADY HAPPENED");

        // make sure the event is under the maximum capacity
        require(
            myEvent.confirmedRSVPs.length < myEvent.maxCapacity,
            "EVENT AT CAPACITY"
        );

        // require that msg.sender isn't already in myEvent.confirmedRSVPs
        for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
            require(myEvent.confirmedRSVPs[i] != msg.sender, "ALREADY RSVP'D");
        }

        myEvent.confirmedRSVPs.push(payable(msg.sender));

        emit NewRSVP(eventId, msg.sender);
    }

    function confirmAllAttendees(bytes32 eventId) external {
        // look up the event
        Event memory myEvent = events[eventId];

        // require that msg.sender is the owner of the event
        require(msg.sender == myEvent.eventOwner, "NOT AUTHORIZED");

        // confirm each attendee
        for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
            confirmAttendee(eventId, myEvent.confirmedRSVPs[i]);
        }
    }

    function confirmAttendee(bytes32 eventId, address attendee) public {
        // look up the event
        Event storage myEvent = events[eventId];

        // require that msg.sender is the owner of the event
        require(msg.sender == myEvent.eventOwner, "NOT AUTHORIZED");

        // require that attendee is in myEvent.confirmedRSVPs
        address rsvpConfirm;

        for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
            if (myEvent.confirmedRSVPs[i] == attendee) {
                rsvpConfirm = myEvent.confirmedRSVPs[i];
            }
        }

        require(rsvpConfirm == attendee, "NO RSVP TO CONFIRM");

        // require that attendee is NOT in the claimedRSVPs list
        for (uint8 i = 0; i < myEvent.claimedRSVPs.length; i++) {
            require(myEvent.claimedRSVPs[i] != attendee, "ALREADY CLAIMED");
        }

        // require that deposits are not already claimed
        require(myEvent.paidOut == false, "ALREADY PAID OUT");

        // add them to the claimedRSVPs list
        myEvent.claimedRSVPs.push(attendee);

        // sending eth back to the staker https://solidity-by-example.org/sending-ether
        (bool sent, ) = attendee.call{value: myEvent.depositAmount}("");

        //if this fails
        if (!sent) {
            myEvent.claimedRSVPs.pop();
        }

        require(sent, "Failed to send Ether");

        emit AttendeeConfirmed(eventId, attendee);
    }

    function withdrawUnclaimedDeposits(bytes32 eventId) external {
        // look up event
        Event memory myEvent = events[eventId];

        // check if already paid
        require(!myEvent.paidOut, "ALREADY PAID");

        // check if it's been 7 days past myEvent.eventTimestamp
        require(block.timestamp >= (myEvent.eventTime + 7 days), "TOO EARLY");

        // only the event owner can withdraw
        require(msg.sender == myEvent.eventOwner, "MUST BE EVENT OWNER");

        // calculate how many people didn't claim by comparing
        uint256 unclaimed = myEvent.confirmedRSVPs.length -
            myEvent.claimedRSVPs.length;

        uint256 payout = unclaimed * myEvent.depositAmount;

        // mark as paid before sending to avoid reentrancy attack
        myEvent.paidOut = true;

        // send the payout to the owner
        (bool sent, ) = msg.sender.call{value: payout}("");

        // if this fails
        if (!sent) {
            myEvent.paidOut = false;
        }

        require(sent, "Failed to send Ether");

        emit DepositsPaidOut(eventId);
    }
}
