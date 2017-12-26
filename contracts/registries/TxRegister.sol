pragma solidity ^0.4.16;


contract TxRegister {

    /* Stracture to hold each trade's details*/
    struct Receipt {
        bytes8 receiptId;
        bytes32 txid1;
        bytes32 txid2;
        address receiverAddress;
        address senderAddress;
        bytes32 assetID;
        uint assetQuantity;
        uint256 totalAmount;
        uint timestamp;
    }

    /* This will create an array of stracures to hold trade details*/ 
    Receipt[] public receipts; 

    struct ReceiptsByAddress {
        bytes8[] receiptId;
    }

    struct ReceiptsByAssetId {
        bytes8[] receiptId;
    }

    /* Different mapping definations */
    mapping(address => ReceiptsByAddress) transactionsByAddress;           //Map user's associated wallet address with his trade receipts 

    mapping(bytes32 => ReceiptsByAssetId) transactionByAssetId;

    mapping(bytes8 => Receipt) receiptsByReceiptId;

    /* Function to add a new transaction*/
    function addTx (
        bytes8 _receiptId,
        bytes32 _assetTxid,
        bytes32 _currencyTxid,
        address _from, address _to,
        bytes32 _assetID,
        uint _assetQuantity,
        uint256 _totalAmount
    ) returns (bool success) 
    {
        Receipt memory newReceipt;
        newReceipt.receiptId = _receiptId;
        newReceipt.txid1 = _assetTxid;
        newReceipt.txid2 = _currencyTxid;
        newReceipt.receiverAddress = _to;
        newReceipt.senderAddress = _from;
        newReceipt.assetID = _assetID;
        newReceipt.assetQuantity = _assetQuantity;
        newReceipt.totalAmount = _totalAmount;
        newReceipt.timestamp = block.timestamp;
        receipts.push(newReceipt);

        transactionByAssetId[_assetID].receiptId.push(_receiptId);
        transactionsByAddress[_from].receiptId.push(_receiptId);
        transactionsByAddress[_to].receiptId.push(_receiptId);
        receiptsByReceiptId[_receiptId] = newReceipt;
        return true;
    }

    /* Function to query a transaction recept by associated wallet address */
    function getReceiptIdsByAddress(address _addr) public constant returns(bytes8[]) {
        uint length = transactionsByAddress[_addr].receiptId.length;
        bytes8[] memory receiptId = new bytes8[](length);
        receiptId = transactionsByAddress[_addr].receiptId;
        return (receiptId);
    }

    // function getReceiptIdsByAssetId(bytes32 _assetId) constant returns(bytes8[]){
    //     uint length = transactionByAssetId[_assetId].receiptId.length;
    //     bytes8[] memory receiptId = new bytes8[](length);
    //     receiptId = transactionByAssetId[_assetId].receiptId;
    //     return (receiptId);
    // }



    function getReceiptByReceiptId(bytes8 _receiptId) public constant returns(
        bytes32,
        bytes32,
        address,
        address,
        bytes32,
        uint,
        uint256
    ) {
        return (
        receiptsByReceiptId[_receiptId].txid1,
        receiptsByReceiptId[_receiptId].txid2,
        receiptsByReceiptId[_receiptId].receiverAddress,
        receiptsByReceiptId[_receiptId].senderAddress,
        receiptsByReceiptId[_receiptId].assetID,
        receiptsByReceiptId[_receiptId].assetQuantity,
        receiptsByReceiptId[_receiptId].totalAmount);
    }

    function getReceiptIdsByAssetId(bytes32 _assetId) public constant returns(bytes8[]) {
        uint length = transactionByAssetId[_assetId].receiptId.length;
        bytes8[] memory receiptId = new bytes8[](length);
        receiptId = transactionByAssetId[_assetId].receiptId;
        return (receiptId);
    }

    /* Function to get all transaction receipts*/
    function getAllTxDetails1() public constant returns (bytes32[] , bytes32[], address[] , address[] , bytes32[]) {

        bytes32[] memory txids1 = new bytes32[](receipts.length);
        bytes32[] memory txids2 = new bytes32[](receipts.length);
        address[] memory senders = new address[](receipts.length);
        address[] memory receivers = new address[](receipts.length);
        bytes32[] memory receiptIds = new bytes32[](receipts.length);
        uint256[] memory totalAmounts = new uint256[](receipts.length);
        uint[] memory assetQuantities = new uint[](receipts.length);
        
        for (var i = 0; i < receipts.length; i++) {

            Receipt memory currentReceipt;
            currentReceipt = receipts[i];
            txids1[i] = currentReceipt.txid1;
            txids2[i] = currentReceipt.txid2;
            senders[i] = currentReceipt.senderAddress;
            receivers[i] = currentReceipt.receiverAddress;
            receiptIds[i] = currentReceipt.receiptId;
        }
        return(txids1, txids2, senders, receivers, receiptIds);
    }

    function getAllTxDetails2() public constant returns (bytes32[] , uint[] , uint256[]) {

        bytes32[] memory assetIDs = new bytes32[](receipts.length);
        uint256[] memory totalAmounts = new uint256[](receipts.length);
        uint[] memory assetQuantities = new uint[](receipts.length);
        uint[] memory timestamps = new uint[](receipts.length);
        
        for (var i = 0; i < receipts.length; i++) {

            Receipt memory currentReceipt;
            currentReceipt = receipts[i];
            assetIDs[i] = currentReceipt.assetID;
            assetQuantities[i] = currentReceipt.assetQuantity;
            totalAmounts[i] = currentReceipt.totalAmount;
            timestamps[i] = currentReceipt.timestamp;
        }
        return(assetIDs, assetQuantities, totalAmounts);
    }

}