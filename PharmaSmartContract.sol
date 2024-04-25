// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILicenseNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function getLicenseData(uint256 tokenId) external view returns (string memory validity, bool isActive);
}

contract SupplyChainPayment {
    address owner;
    address payable public manufacturer;
    address payable public transporter1;
    address payable public distributor;
    address payable public transporter2;
    address payable public retailPharmacy;
    uint256 public licenseNftTokenId;
    ILicenseNFT public licenseNftContract;

    enum Stage { Created, InTransit, Delivered, InDistribution, FinalDelivery, Completed }
    Stage public stage = Stage.Created;

    constructor(
        address _manufacturer,
        address _transporter1,
        address _distributor,
        address _transporter2,
        address _retailPharmacy,
        uint256 _licenseNftTokenId,
        address _licenseNftContract
    ) {
        owner = msg.sender;
        manufacturer = payable(_manufacturer);
        transporter1 = payable(_transporter1);
        distributor = payable(_distributor);
        transporter2 = payable(_transporter2);
        retailPharmacy = payable(_retailPharmacy);
        licenseNftTokenId = _licenseNftTokenId;
        licenseNftContract = ILicenseNFT(_licenseNftContract);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function verifyManufacturerLicense() public view returns (bool) {
        address nftOwner = licenseNftContract.ownerOf(licenseNftTokenId);
        (, bool isActive) = licenseNftContract.getLicenseData(licenseNftTokenId);
        return nftOwner == manufacturer && isActive;
    }

    function advanceStage() public onlyOwner {
        require(stage != Stage.Completed, "Transaction is already completed.");
        require(verifyManufacturerLicense(), "Manufacturer's license is invalid or not active.");

        stage = Stage(uint(stage) + 1);

        if(stage == Stage.InTransit) {
            pay(transporter1, 100); // Example payment amount
        } else if(stage == Stage.Delivered) {
            pay(distributor, 150); // Adjust as necessary
        } else if(stage == Stage.InDistribution) {
            pay(transporter2, 100); // Adjust as necessary
        } else if(stage == Stage.FinalDelivery) {
            pay(retailPharmacy, 200); // Adjust as necessary
        }
    }

    function pay(address payable recipient, uint amount) private {
        require(address(this).balance >= amount, "Insufficient balance.");
        recipient.transfer(amount);
    }

    // Function to deposit funds into the contract
    function deposit() public payable onlyOwner {}

    // Check balance (for owner)
    function checkBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }
}