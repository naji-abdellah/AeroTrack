// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AeroTrack {

    // Enum to track the physical state of the part
    enum PartStatus { Manufactured, InTransit, Installed, Retired }

    // Struct representing an airplane spare part
    struct Part {
        uint256 serialNumber;
        string partName;
        address manufacturer;
        address currentOwner;
        PartStatus status;
        bool exists; // Security flag to check if part was actually created
    }

    // State variable: The deployer becomes the regulatory authority (e.g. FAA or EASA)
    address public regulatoryAuthority;

    // Mapping a Serial Number to a Part struct
    mapping(uint256 => Part) public parts;

    // --- EVENTS ---
    event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer);
    event OwnershipTransferred(uint256 indexed serialNumber, address oldOwner, address newOwner);
    event MaintenanceLogged(uint256 indexed serialNumber, address mechanic, string report);

    // Constructor runs once during deployment
    constructor() {
        regulatoryAuthority = msg.sender; // The deployer is the authority
    }

    // --- MODIFIERS ---

    // 1. Ensure the caller is the regulatory authority
    modifier onlyAuthority() {
        require(msg.sender == regulatoryAuthority, "Error: You are not the Authority.");
        _;
    }

    // 2. Ensure a part actually exists before interacting with it
    modifier partExists(uint256 _serialNumber) {
        require(parts[_serialNumber].exists == true, "Error: Part does not exist in registry.");
        _;
    }

    // 3. Ensure only the current owner of a specific part can modify it
    modifier onlyPartOwner(uint256 _serialNumber) {
        require(parts[_serialNumber].currentOwner == msg.sender, "Not the owner.");
        _;
    }

    // --- CORE FUNCTIONS ---

    // Function to register a newly manufactured part
    function manufacturePart(uint256 _serialNumber, string memory _partName) public {
        // Security check: ensure serial number isn't already used
        require(parts[_serialNumber].exists == false, "Error: Serial Number already registered!");

        // Create the part in storage
        parts[_serialNumber] = Part({
            serialNumber: _serialNumber,
            partName: _partName,
            manufacturer: msg.sender,
            currentOwner: msg.sender, // Manufacturer owns it initially
            status: PartStatus.Manufactured,
            exists: true
        });

        emit PartManufactured(_serialNumber, _partName, msg.sender);
    }

    // Function to transfer the part to a new owner (e.g. an Airline)
    function transferPart(uint256 _serialNumber, address _newOwner)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        require(_newOwner != address(0), "Error: Cannot transfer to zero address.");

        address oldOwner = parts[_serialNumber].currentOwner;
        parts[_serialNumber].currentOwner = _newOwner;
        parts[_serialNumber].status = PartStatus.InTransit;

        emit OwnershipTransferred(_serialNumber, oldOwner, _newOwner);
    }

    // Function to log a maintenance report on a part
    function logMaintenance(uint256 _serialNumber, string memory _report)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        // Emit an event containing the maintenance report
        // This permanently stamps the report on the blockchain ledger
        emit MaintenanceLogged(_serialNumber, msg.sender, _report);

        // Update status to Installed (assuming maintenance implies active use)
        parts[_serialNumber].status = PartStatus.Installed;
    }
}
