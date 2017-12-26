pragma solidity ^0.4.8;

contract AssetTypes{

    struct subType{
        bytes32[] subTypeName;
    }

    mapping(bytes32=>subType) mapSubTypes;
    mapping(bytes32=>uint) mapSubTypesWithTimestamps;

    struct assetIds{
        bytes32[] assetId;
    }

    mapping(bytes32=>assetIds) mapAssetIdsWithSubTypes;

    function addNewAssetSubType(bytes32 _typeName,bytes32 _subTypeName,uint _timestamp,bytes32 _assetId) returns (bool success){
        mapSubTypes[_typeName].subTypeName.push(_subTypeName);  
        mapSubTypesWithTimestamps[_subTypeName] = _timestamp;
        addAssetIdsPerSubTypes(_subTypeName,_assetId);

        return true;
    }

    function addAssetIdsPerSubTypes(bytes32 _subTypeName,bytes32 _assetId) returns (bool success){
        mapAssetIdsWithSubTypes[_subTypeName].assetId.push(_assetId);
        return true;
    }

    function getSubTypes(bytes32 _typeName) constant returns (bytes32[],uint[]){
        uint length = mapSubTypes[_typeName].subTypeName.length;
        bytes32[] memory subTypes = new bytes32[](length);
        uint[] memory timestamps = new uint[](length);
        subTypes = mapSubTypes[_typeName].subTypeName;
        for (uint i = 0; i<length;i++ ){
            bytes32 subtype = subTypes[i];
            timestamps[i] = mapSubTypesWithTimestamps[subtype];
        }
        return (subTypes,timestamps);
    }

    function getAssetIdsForSubTypes(bytes32 _subTypeName) constant returns(bytes32[]){
        return (mapAssetIdsWithSubTypes[_subTypeName].assetId);
    }
}