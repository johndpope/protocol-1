pragma solidity ^0.4.8;

contract MPAssetRequests{

    
    struct newMPAssetRequest{
        bytes32 assetName;
        bytes32 assetType;
        bytes32 asseetSubType;
        bytes32 companyName;
        uint timestamp;
        bytes8 requestId;
    }

    newMPAssetRequest[] public allMPLevelAssetRequests;
    mapping(bytes8=>newMPAssetRequest) public MPAssetById;
    mapping(bytes8=>bool) public MPAssetStatus;

    struct MPAssetRequestsByUser{
        bytes8[] requestId;
    }

    mapping (address=>MPAssetRequestsByUser) MPLevelAssetRequestsByUser;

    function addNewMPAssetRequest(bytes32 _assetSubType,bytes8 _requestId, bytes32 _assetName, bytes32 _companyName, address _requestRaiser, bytes32 _assetType, bytes32 _assetID) returns (bool _status){

        newMPAssetRequest memory newRequest;
        newRequest.assetName = _assetName;
        newRequest.assetType = _assetType;
        newRequest.companyName = _companyName;
        newRequest.asseetSubType = _assetSubType;
        newRequest.timestamp = block.timestamp;
        allMPLevelAssetRequests.push(newRequest);

        MPLevelAssetRequestsByUser[_requestRaiser].requestId.push(_requestId);
        MPAssetById[_requestId] = newRequest;
        MPAssetStatus[_requestId] = false;

        return true;
    }

    function getRequestIdsByAddress(address _user) constant returns(bytes8[]){
        uint length = MPLevelAssetRequestsByUser[_user].requestId.length;
        bytes8[] memory requestIds = new bytes8[](length);
        requestIds = MPLevelAssetRequestsByUser[_user].requestId;
        return (requestIds);
    }

    function getMPAssetRequestsById(bytes8 _requestId) constant returns(bytes32,bytes32,bytes32,bytes32,uint,bool){
        return(MPAssetById[_requestId].assetName,MPAssetById[_requestId].assetType,MPAssetById[_requestId].companyName,MPAssetById[_requestId].asseetSubType,MPAssetById[_requestId].timestamp,MPAssetStatus[_requestId]);
    }

    function getAllMPAssetRequestsForAdd() constant returns (bytes32[],bytes32[],bytes32[],bytes32[],uint[],bytes8[]){
        uint length = allMPLevelAssetRequests.length;
        bytes32[] memory assetNames = new bytes32[](length);
        bytes32[] memory assetTypes = new bytes32[](length);
        bytes32[] memory companyNames = new bytes32[](length);
        bytes32[] memory asseetSubTypes = new bytes32[](length);
        uint[] memory timestamps = new uint[](length);
        bytes8[] memory requestIds = new bytes8[](length);

            for (var i = 0; i < length; i++) {

                newMPAssetRequest memory currentRequest;
                currentRequest = allMPLevelAssetRequests[i];
                
                if(!MPAssetStatus[currentRequest.requestId])
                {
                    assetNames[i] = currentRequest.assetName;
                    assetTypes[i] = currentRequest.assetType;
                    companyNames[i] = currentRequest.companyName;
                    asseetSubTypes[i] = currentRequest.asseetSubType;
                    timestamps[i] = currentRequest.timestamp;
                    requestIds[i] = currentRequest.requestId;
                }
            }
            return(assetNames,assetTypes,companyNames,asseetSubTypes,timestamps,requestIds);
    }

    function getMPAllAssetRequests() constant returns (bytes32[],bytes32[],bytes32[],bytes32[],uint[],bytes8[]){
       // uint length = allMPLevelAssetRequests.allMPLevelAssetRequests.length;
        bytes32[] memory assetNames = new bytes32[](allMPLevelAssetRequests.length);
        bytes32[] memory assetTypes = new bytes32[](allMPLevelAssetRequests.length);
        bytes32[] memory companyNames = new bytes32[](allMPLevelAssetRequests.length);
        bytes32[] memory asseetSubTypes = new bytes32[](allMPLevelAssetRequests.length);
        uint[] memory timestamps = new uint[](allMPLevelAssetRequests.length);
        bytes8[] memory requestIds = new bytes8[](allMPLevelAssetRequests.length);
        bool[] memory status = new bool[](allMPLevelAssetRequests.length);
            
            for (var i = 0; i < allMPLevelAssetRequests.length; i++) {

                newMPAssetRequest memory currentRequest;
                currentRequest = allMPLevelAssetRequests[i];
                assetNames[i] = currentRequest.assetName;
                assetTypes[i] = currentRequest.assetType;
                companyNames[i] = currentRequest.companyName;
                asseetSubTypes[i] = currentRequest.asseetSubType;
                timestamps[i] = currentRequest.timestamp;
                status[i] = MPAssetStatus[currentRequest.requestId];
                requestIds[i] = currentRequest.requestId;

            }
            return(assetNames,assetTypes,companyNames,asseetSubTypes,timestamps,requestIds);
    }

    // function getNewMPAssetRequestByWalletAddress(address _user) constant returns(bytes8[],bytes32[],bytes32[],bytes32[],bytes32[],uint[]){
    //     uint length = MPLevelAssetRequestsByUser[_user].requestId.length;
    //     bytes32[] memory assetNames = new bytes32[](length);
    //     bytes32[] memory assetTypes = new bytes32[](length);
    //     bytes32[] memory companyNames = new bytes32[](length);
    //     bytes32[] memory asseetSubTypes = new bytes32[](length);
    //     uint[] memory timestamps = new uint[](length);
    //     bytes8[] memory requestIds = new bytes8[](length);
       
    //     requestIds = MPLevelAssetRequestsByUser[_user].requestId;
        
    //     for (var i = 0; i < MPLevelAssetRequestsByUser[_user].requestId.length; i++){
    //         bytes8 requestId = requestIds[i];
    //         assetNames[i] = MPAssetById[requestId].assetName;
    //         assetTypes[i] = MPAssetById[requestId].assetType;
    //         companyNames[i] = MPAssetById[requestId].companyName;
    //         asseetSubTypes[i] = MPAssetById[requestId].asseetSubType;
    //         timestamps[i] = MPAssetById[requestId].timestamp;
        
    //     }
    //     return(requestIds,assetNames,assetTypes,companyNames,asseetSubTypes,timestamps);
    // }

    function changeMPAssetRequestStatus(bytes8 _requestId) returns (bool success){
        MPAssetStatus[_requestId] = true;
        return true;
    }

    function getMPAssetRequestStatus(bytes8 _requestId) constant returns (bool){
        return MPAssetStatus[_requestId];
    }

}