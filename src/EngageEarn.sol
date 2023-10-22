// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
// import "./IInterchainQueryRouter.sol";
import "sismo-connect-solidity/SismoConnectLib.sol";
import "forge-std/console.sol";

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external;

    function transfer(address to, uint amount) external;

    function approve(address to, uint amount) external returns (bool);

    function balanceOf(address user) external returns (uint);
}

interface ISavingsDai {
    function deposit(uint256 assets, address receiver) external returns (uint);

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256);

    function increaseAllowance(address to, uint amount) external returns (bool);

    function convertToShares(uint256 assets) external view returns (uint256);
}

contract EngageEarn is SismoConnect {
    // contract EngageEarn {
    address dai;
    address sDAI;

    mapping(address => bool) public isRegistered;
    mapping(address => uint) public org2Id;
    mapping(uint => address) public Id2Org;
    mapping(uint => uint) public campaignPrizePool;
    mapping(uint => uint) public campaignOwner;
    mapping(uint => address[]) public campaignParticipants;
    mapping(uint => bytes16) public campaign2GroupId;
    mapping(address => uint) public sDaiShares;
    uint public orgId;
    uint public campaignId;

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
    // bytes16 public constant GROUP_ID = 0x843d4092ffba2a5b069f618dd7b6895d;

    constructor(
        address _dai,
        address _sDAI
    ) SismoConnect(buildConfig(_appId, _isImpersonationMode)) {
        dai = _dai;
        sDAI = _sDAI;
        address a = 0xB35C75920A3ea63D892C4CC5d0AF1f6272c00e3D;
        address b = 0x069948953deFa9CE2177a546e6d6801c51A315da;
        sDaiShares[a] = 97852903775166491731156; // 100k DAI
        sDaiShares[b] = 97852903775166491731156;
        address me = 0xd9055449653f640Add40afba13a5f5AF61200d64;
        campaignParticipants[0].push(me);
        campaignParticipants[0].push(a);
    }

    // constructor(address _dai, address _sDAI) {
    //     dai = _dai;
    //     sDAI = _sDAI;
    // }

    function createCampaignPool(uint256 shares, bytes16 groupId) public {
        address creator = msg.sender;
        require(isRegistered[creator], "not registered");
        require(sDaiShares[creator] >= shares, "insufficient shares");
        sDaiShares[creator] -= shares;
        // approve
        // ISavingsDai(sDAI).increaseAllowance(address(this), shares);
        uint assets = ISavingsDai(sDAI).redeem(
            shares,
            address(this),
            address(this)
        );
        campaign2GroupId[campaignId] = groupId;
        campaignOwner[campaignId] = org2Id[creator];
        campaignPrizePool[campaignId++] = assets;
    }

    function convertAssetsToShares(uint assets) external returns (uint) {
        return ISavingsDai(sDAI).convertToShares(assets);
    }

    function checkMember(
        bytes memory response,
        uint _campaignId
    ) public returns (bool) {
        SismoConnectVerifiedResult memory result = verify({
            responseBytes: response,
            // we want the user to prove that he owns a Sismo Vault
            // we are recreating the auth request made in the frontend to be sure that
            // the proofs provided in the response are valid with respect to this auth request
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({
                groupId: campaign2GroupId[_campaignId],
                value: 1,
                claimType: ClaimType.GTE
            }),
            // we also want to check if the signed message provided in the response is the signature of the user's address
            signature: buildSignature({message: abi.encode(msg.sender)})
        });

        campaignParticipants[_campaignId].push(msg.sender);

        return true;
    }

    // function mockInsertParticipants(
    //     uint _campaignId,
    //     address a,
    //     address b
    // ) external {
    //     campaignParticipants[_campaignId].push(a);
    //     campaignParticipants[_campaignId].push(b);
    // }

    function rewardCampaignParticipants(uint _campaignId) external {
        uint totalReward = campaignPrizePool[_campaignId];
        address[] memory participants = campaignParticipants[_campaignId];
        uint totalParticipantsCount = participants.length;
        uint rewardPerParticipant = (totalReward) / totalParticipantsCount;
        console.log(
            "EngageEarn dai balance ",
            IERC20(dai).balanceOf(address(this))
        );

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
    function depositDAIFunds(uint amount) public {
        // the organisation must be registered before depositing funds
        require(isRegistered[msg.sender], "org not registered");
        // recieve dai from the org
        console.log("upar ", amount);

        IERC20(dai).transferFrom(msg.sender, address(this), amount);
        // deposit to sDAI
        IERC20(dai).approve(sDAI, type(uint256).max);
        // ISavingsDai(sDAI).deposit(amount, msg.sender);
        uint shares = ISavingsDai(sDAI).deposit(amount, address(this));
        sDaiShares[msg.sender] += shares;
    }
}
