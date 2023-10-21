// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
// import "./IInterchainQueryRouter.sol";
import "sismo-connect-solidity/SismoConnectLib.sol";

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external;

    function transfer(address to, uint amount) external;
}

interface ISavingsDai {
    function deposit(uint256 assets, address receiver) external payable;

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external payable;
}

contract EngageEarn is SismoConnect {
    address dai;
    address sDAI;

    mapping(address => bool) isRegistered;
    mapping(address => uint) org2Id;
    mapping(uint => address) Id2Org;
    mapping(uint => uint) campaignPrizePool;
    mapping(uint => uint) campaignOwner;
    mapping(uint => address[]) campaignParticipants;
    uint orgId;
    uint campaignId;

    event CampaignRewardDistributed(
        address recipient,
        uint campaignOwner,
        uint campaignId,
        uint reward
    ); // add your appId
    bytes16 private _appId = 0x13acd90f1ab192cdd936293ee2ea759f;
    // use impersonated mode for testing
    bool private _isImpersonationMode = true;
    // foundry contributors
    bytes16 public constant GROUP_ID = 0x843d4092ffba2a5b069f618dd7b6895d;

    constructor(
        address _dai,
        address _sDAI
    ) SismoConnect(buildConfig(_appId, _isImpersonationMode)) {
        dai = _dai;
        sDAI = _sDAI;
    }

    function createCampaignPool(uint256 shares, uint assets) public payable {
        address creator = msg.sender;
        require(isRegistered[creator], "not registered");
        ISavingsDai(sDAI).redeem{value: msg.value}(
            shares,
            address(this),
            creator
        );
        campaignOwner[campaignId] = org2Id[creator];
        campaignPrizePool[campaignId++] = assets;
    }

    function checkMember(
        bytes memory response,
        uint campaignId
    ) public view returns (bool) {
        SismoConnectVerifiedResult memory result = verify({
            responseBytes: response,
            // we want the user to prove that he owns a Sismo Vault
            // we are recreating the auth request made in the frontend to be sure that
            // the proofs provided in the response are valid with respect to this auth request
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({
                groupId: GROUP_ID,
                value: 1,
                claimType: ClaimType.GTE
            }),
            // we also want to check if the signed message provided in the response is the signature of the user's address
            signature: buildSignature({message: abi.encode(msg.sender)})
        });

        campaignParticipants[campaignId].push(msg.sender);

        return true;
    }

    function rewardCampaignParticipants(uint _campaignId) external {
        uint totalReward = campaignPrizePool[_campaignId];
        address[] memory participants = campaignParticipants[_campaignId];
        uint totalParticipantsCount = participants.length;
        uint rewardPerParticipant = (totalReward * 1 ether) /
            totalParticipantsCount;

        for (uint i; i < totalParticipantsCount; i++) {
            IERC20(dai).transfer(participants[i], rewardPerParticipant);
            emit CampaignRewardDistributed(
                participants[i],
                campaignOwner[_campaignId],
                _campaignId,
                rewardPerParticipant
            );
        }
    }

    function registerOrg() external returns (uint) {
        require(!isRegistered[msg.sender], "already registered");
        isRegistered[msg.sender] = true;
        org2Id[msg.sender] = orgId;
        Id2Org[orgId++] = msg.sender;
    }

    /// deposit DAI to the SavingsDai contract and enjoy risk-minimised stablecoin yield.
    function depositDAIFunds(uint amount) public payable {
        // the organisation must be registered before depositing funds
        require(isRegistered[msg.sender], "org not registered");
        // recieve dai from the org
        IERC20(dai).transferFrom(msg.sender, address(this), amount);
        // deposit to sDAI
        ISavingsDai(sDAI).deposit{value: msg.value}(amount, msg.sender);
    }
}
