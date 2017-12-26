pragma solidity ^0.4.8;

contract AssetRequest{

    struct newAssetRequest{
        bytes32 requestId;
        bytes32 assetName;
        bytes32 companyName;
        bytes32 assetType;
        bytes32 asseetSubType;
        uint timestamp;
        }
    
    newAssetRequest[] public allNewAssetRequests;

    mapping (bytes32=>newAssetRequest) public assetRequestsByRequestIds;
    mapping (bytes32=>bool) public newAssetRequestStatus;
    
    struct assetRequestsByUser{
        bytes32[] requestId;
    }

    mapping(address=>assetRequestsByUser) requestsByUsers;

    uint i;

    function addNewAssetRequest(bytes32 _assetSubType,bytes32 _requestId, bytes32 _assetName, bytes32 _companyName, address _requestRaiser, bytes32 _assetType, bytes32 _assetID) returns (bool _status){

        newAssetRequest memory newRequest;
        newRequest.assetName = _assetName;
        newRequest.assetType = _assetType;
        newRequest.companyName = _companyName;
        newRequest.asseetSubType = _assetSubType;
        newRequest.timestamp = block.timestamp;
        allNewAssetRequests.push(newRequest);

        requestsByUsers[_requestRaiser].requestId.push(_requestId);
        assetRequestsByRequestIds[_requestId] = newRequest;
        newAssetRequestStatus[_requestId] = false;

        return true;
    }

    function getAssetRequestIdsByAddress(address _user) constant returns(bytes32[]){
        uint length = requestsByUsers[_user].requestId.length;
        bytes32[] memory requestIds = new bytes32[](length);
        requestIds = requestsByUsers[_user].requestId;
        return (requestIds);
    }

    function getAssetRequestsById(bytes8 _requestId) constant returns(bytes32,bytes32,bytes32,bytes32,uint,bool){
        return(assetRequestsByRequestIds[_requestId].assetName,assetRequestsByRequestIds[_requestId].assetType,assetRequestsByRequestIds[_requestId].companyName,assetRequestsByRequestIds[_requestId].asseetSubType,assetRequestsByRequestIds[_requestId].timestamp,newAssetRequestStatus[_requestId]);
    }

    function getAllAssetRequestsForApproval() constant returns (bytes32[],bytes32[],bytes32[],bytes32[],uint[],bytes32[]){
        uint length = allNewAssetRequests.length;
        bytes32[] memory assetNames = new bytes32[](length);
        bytes32[] memory assetTypes = new bytes32[](length);
        bytes32[] memory companyNames = new bytes32[](length);
        bytes32[] memory asseetSubTypes = new bytes32[](length);
        uint[] memory timestamps = new uint[](length);
        bytes32[] memory requestIds = new bytes32[](length);

            for (i = 0; i < length; i++) {

                newAssetRequest memory currentRequest;
                currentRequest = allNewAssetRequests[i];
                
                if(!newAssetRequestStatus[currentRequest.requestId])
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

    function getAllAssetRequests() constant returns (bytes32[],bytes32[],bytes32[],bytes32[],uint[],bytes32[],bool[]){
        //uint length = allNewAssetRequests.length;
        bytes32[] memory assetNames = new bytes32[](allNewAssetRequests.length);
        bytes32[] memory assetTypes = new bytes32[](allNewAssetRequests.length);
        bytes32[] memory companyNames = new bytes32[](allNewAssetRequests.length);
        bytes32[] memory asseetSubTypes = new bytes32[](allNewAssetRequests.length);
        uint[] memory timestamps = new uint[](allNewAssetRequests.length);
        bytes32[] memory requestIds = new bytes32[](allNewAssetRequests.length);
        bool[] memory requestStatuses = new bool[](allNewAssetRequests.length);

            for (var i = 0; i < allNewAssetRequests.length; i++) {

                newAssetRequest memory currentRequest;
                currentRequest = allNewAssetRequests[i];
                assetNames[i] = currentRequest.assetName;
                assetTypes[i] = currentRequest.assetType;
                companyNames[i] = currentRequest.companyName;
                asseetSubTypes[i] = currentRequest.asseetSubType;
                timestamps[i] = currentRequest.timestamp;
                requestIds[i] = currentRequest.requestId;
                requestStatuses[i] = newAssetRequestStatus[currentRequest.requestId];
            }
            return(assetNames,assetTypes,companyNames,asseetSubTypes,timestamps,requestIds,requestStatuses);
    }

    // function getNewAssetRequestByWalletAddress(address _user) constant returns(bytes32[],bytes32[],bytes32[],bytes32[],bytes32[],uint[],bool[]){
    //     uint length = requestsByUsers[_user].requestId.length;
    //     bytes32[] memory assetNames = new bytes32[](length);
    //     bytes32[] memory assetTypes = new bytes32[](length);
    //     bytes32[] memory companyNames = new bytes32[](length);
    //     bytes32[] memory asseetSubTypes = new bytes32[](length);
    //     uint[] memory timestamps = new uint[](length);
    //     bytes32[] memory requestIds = new bytes32[](length);
    //     bool[] memory requestStatuses = new bool[](length);

    //     requestIds = requestsByUsers[_user].requestId;
    //     for (var i = 0; i < length; i++){
    //         bytes32 requestId = requestIds[i];
    //         assetNames[i] = assetRequestsByRequestIds[requestId].assetName;
    //         assetTypes[i] = assetRequestsByRequestIds[requestId].assetType;
    //         companyNames[i] = assetRequestsByRequestIds[requestId].companyName;
    //         asseetSubTypes[i] = assetRequestsByRequestIds[requestId].asseetSubType;
    //         timestamps[i] = assetRequestsByRequestIds[requestId].timestamp;
    //         requestStatuses[i] = newAssetRequestStatus[requestId];
    //     }
    //     return(requestIds,assetNames,assetTypes,companyNames,asseetSubTypes,timestamps,requestStatuses);
    // }

    function approveAssetRequest(bytes32 _requestId) returns (bool success){
        newAssetRequestStatus[_requestId] = true;
        return true;
    }

    function getRequestStatus(bytes32 _requestId) constant returns (bool){
        return newAssetRequestStatus[_requestId];
    }

}