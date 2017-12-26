pragma solidity ^0.4.8;


contract REAssets{

    struct newREAssetRequest{
        bytes32 assetName;
        bytes32 add1;
        bytes32 asseetSubType;
        uint timestamp;
        bytes32 lat;
        bytes32 long;
        bytes32 assetId;
    }
    
    newREAssetRequest[] public allNewREAssetRequests;

    mapping (bytes32=>mapping(address=>uint256)) mapOfferPriceWithRE;
    mapping (bytes32=>mapping(address=>uint256)) mapAquisitionPrice;
    mapping (bytes32=>address) mapREAssetsWithAddress;
    mapping (bytes32=>bool) public newREAssetRequestStatus;
    mapping (bytes32=>newREAssetRequest) REAssetRequestsByAssetId;
        
    struct REAssetsByUser{
        bytes32[] assetId;
    }

    mapping(address=>REAssetsByUser) REAssetsByUsers;

    uint i;

    function addNewREAssetRequest(address _requestRaiser,bytes32 _assetSubType, bytes32 _assetName, bytes32 _add1, bytes32 _lat, bytes32 _long,bytes32 _assetID) returns (bool _status){

        newREAssetRequest memory newRequest;
        newRequest.assetName = _assetName;
        newRequest.add1 = _add1;
        newRequest.assetId = _assetID;
        newRequest.lat = _lat;
        newRequest.long = _long;
        newRequest.asseetSubType = _assetSubType;
        newRequest.timestamp = block.timestamp;
        allNewREAssetRequests.push(newRequest);

        newREAssetRequestStatus[_assetID] = false;
        mapREAssetsWithAddress[_assetID] = _requestRaiser; 
        REAssetsByUsers[_requestRaiser].assetId.push(_assetID);
        REAssetRequestsByAssetId[_assetID] = newRequest;
        return true;
    }

    function addNewREAssetByAdmin( bytes32 _assetName,bytes32 _assetSubType, bytes32 _add1, bytes32 _lat, bytes32 _long,bytes32 _assetID)returns(bool success){
        newREAssetRequest memory newRequest;
        newRequest.assetName = _assetName;
        newRequest.add1 = _add1;
        newRequest.assetId = _assetID;
        newRequest.lat = _lat;
        newRequest.long = _long;
        newRequest.asseetSubType = _assetSubType;
        newRequest.timestamp = block.timestamp;
        allNewREAssetRequests.push(newRequest);
        REAssetRequestsByAssetId[_assetID] = newRequest;
    }

    function addNewREAssetByBuyer( address _requestRaiser, uint256 _aquisitionPrice, uint256 _OfferPrice, bytes32 _assetID) returns (bool _success){
        uint count =0;
        mapOfferPriceWithRE[_assetID][_requestRaiser] = _OfferPrice;
        mapAquisitionPrice[_assetID][_requestRaiser] = _aquisitionPrice;
        bytes32[] memory assetIds = new bytes32[](REAssetsByUsers[_requestRaiser].assetId.length);
        assetIds = REAssetsByUsers[_requestRaiser].assetId;
        for(i=0;i<REAssetsByUsers[_requestRaiser].assetId.length;i++){
            if(_assetID == assetIds[i]){
                count++;
            }
        }
        if(count==0){
            mapREAssetsWithAddress[_assetID] = _requestRaiser; 
            REAssetsByUsers[_requestRaiser].assetId.push(_assetID);
            return true;
        }
        else{
            return true;
        }
    }

    function updateOfferPrice(bytes32 _assetId, address _requestRaiser, uint256 _OfferPrice) returns (bool success){
        mapOfferPriceWithRE[_assetId][_requestRaiser] = _OfferPrice;
        return true;
    }

    function getOfferPriceForRE(bytes32 _assetId, address _requestRaiser) constant returns(uint256){
        return (mapOfferPriceWithRE[_assetId][_requestRaiser]);
    }

    function getAquisitionPrice(bytes32 _assetId,address _owner) constant returns(uint256){
        return (mapAquisitionPrice[_assetId][_owner]);
    }

    function getREAssetIdsByAddress(address _user) constant returns(bytes32[]){
        uint length = REAssetsByUsers[_user].assetId.length;
        bytes32[] memory assetIds = new bytes32[](REAssetsByUsers[_user].assetId.length);
        assetIds = REAssetsByUsers[_user].assetId;
        return (assetIds);
    }

    function approveAssetRequest(bytes32 _assetID) returns (bool success){
        newREAssetRequestStatus[_assetID] = true;
        return true;
    }

    function getRequestStatus(bytes32 _assetID) constant returns (bool){
        return newREAssetRequestStatus[_assetID];
    }

    function transferAssetsAfterSell(address _from, address _to, bytes32 _assetId) returns (bool success){
        if (mapREAssetsWithAddress[_assetId] != _from) throw; 
        mapREAssetsWithAddress[_assetId] = _to;
        REAssetsByUsers[_to].assetId.push(_assetId);
        return true;
   }

    function getREAssetsDetailsById(bytes32 _assetId) constant returns(bytes32,bytes32,uint,bytes32,bytes32,bytes32,address){
        return(REAssetRequestsByAssetId[_assetId].assetName,
        REAssetRequestsByAssetId[_assetId].asseetSubType,
        REAssetRequestsByAssetId[_assetId].timestamp,
        REAssetRequestsByAssetId[_assetId].add1,
        REAssetRequestsByAssetId[_assetId].lat,
        REAssetRequestsByAssetId[_assetId].long,
        mapREAssetsWithAddress[_assetId]);
    }

    function getAllREAssetBasicDetailsForApproval() constant returns (bytes32[],bytes32[],bytes32[],uint[],bytes32[],bytes32[],bytes32[]){
        bytes32[] memory assetNames = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory add1s = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory lats = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory longs = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory asseetSubTypes = new bytes32[](allNewREAssetRequests.length);
        uint[] memory timestamps = new uint[](allNewREAssetRequests.length);
        bytes32[] memory assetIds = new bytes32[](allNewREAssetRequests.length);

            for (i = 0; i < allNewREAssetRequests.length; i++) {

                newREAssetRequest memory currentRequest;
                currentRequest = allNewREAssetRequests[i];
                
                if(!newREAssetRequestStatus[currentRequest.assetId])
                {
                    assetNames[i] = currentRequest.assetName;
                    add1s[i] = currentRequest.add1;
                    asseetSubTypes[i] = currentRequest.asseetSubType;
                    timestamps[i] = currentRequest.timestamp;
                    assetIds[i] = currentRequest.assetId;
                    lats[i] = currentRequest.lat;
                    longs[i] = currentRequest.long;
                }
            }
            return(assetIds,add1s,asseetSubTypes,timestamps,assetNames,lats,longs);
    }

    function getAllApproavedREAssetDetails() constant returns (bytes32[],bytes32[],bytes32[],bytes32[],bytes32[],bytes32[]){
        bytes32[] memory assetNames = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory add1s = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory lats = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory longs = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory asseetSubTypes = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory assetIds = new bytes32[](allNewREAssetRequests.length);

            for (i = 0; i < allNewREAssetRequests.length; i++) {

                newREAssetRequest memory currentRequest;
                currentRequest = allNewREAssetRequests[i];
                
                if(newREAssetRequestStatus[currentRequest.assetId])
                {
                    assetNames[i] = currentRequest.assetName;
                    add1s[i] = currentRequest.add1;
                    asseetSubTypes[i] = currentRequest.asseetSubType;
                    assetIds[i] = currentRequest.assetId;
                    lats[i] = currentRequest.lat;
                    longs[i] = currentRequest.long;
                }
            }
            return(assetIds,add1s,asseetSubTypes,timestamps,assetNames,lats,longs);
    }

      function getAllREAssetDetails() constant returns (bytes32[],bytes32[],bytes32[],uint[],bytes32[],bytes32[],bytes32[]){
        bytes32[] memory assetNames = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory add1s = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory lats = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory longs = new bytes32[](allNewREAssetRequests.length);
        bytes32[] memory asseetSubTypes = new bytes32[](allNewREAssetRequests.length);
        uint[] memory timestamps = new uint[](allNewREAssetRequests.length);
        bytes32[] memory assetIds = new bytes32[](allNewREAssetRequests.length);

            for (i = 0; i < allNewREAssetRequests.length; i++) {

                newREAssetRequest memory currentRequest;
                currentRequest = allNewREAssetRequests[i];
                
                    assetNames[i] = currentRequest.assetName;
                    add1s[i] = currentRequest.add1;
                    asseetSubTypes[i] = currentRequest.asseetSubType;
                    timestamps[i] = currentRequest.timestamp;
                    assetIds[i] = currentRequest.assetId;
                    lats[i] = currentRequest.lat;
                    longs[i] = currentRequest.long;
                
            }
            return(assetIds,add1s,asseetSubTypes,timestamps,assetNames,lats,longs);
    }


    // function getREAssetsDetailsById(address _user) constant returns(bytes32[],bytes32[],bytes32[],uint[], bytes32[],bytes32[],bytes32[]){
    //     uint length = REAssetsByUsers[_user].assetId.length;
    //     bytes32[] memory assetNames = new bytes32[](length);
    //     bytes32[] memory add1s = new bytes32[](length);
    //     bytes32[] memory asseetSubTypes = new bytes32[](length);
    //     uint[] memory timestamps = new uint[](length);
    //     bytes32[] memory _assetIds = new bytes32[](length);
    //     bytes32[] memory lats = new bytes32[](length);
    //     bytes32[] memory longs = new bytes32[](length);
    //     _assetIds = REAssetsByUsers[_user].assetId;
        
    //     for (i = 0; i < length; i++) {
                
    //             assetNames[i] = REAssetRequestsByAssetId[_assetIds[1]].assetName;
    //             asseetSubTypes[i] = REAssetRequestsByAssetId[_assetIds[1]].asseetSubType;
    //             timestamps[i] = REAssetRequestsByAssetId[_assetIds[1]].timestamp;
    //             add1s[i] = REAssetRequestsByAssetId[_assetIds[1]].add1;
    //             lats[i] = REAssetRequestsByAssetId[_assetIds[1]].lat;
    //             longs[i] = REAssetRequestsByAssetId[_assetIds[1]].long;
    //         }
    //     return(_assetIds,add1s,asseetSubTypes,timestamps,assetNames,lats,longs);
    // }

}