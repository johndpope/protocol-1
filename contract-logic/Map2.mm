<map version="1.0.1">
  <node TEXT="/home/ryan/Git/protocol/TOKENBNK">
    <node TEXT="assets">
      <node TEXT="adapters">
        <node TEXT="ApprovalReceiver.sol" />
        <node TEXT="CompatReceiveAdapter.sol" />
        <node TEXT="ERC20ReceiveAdapter.sol" />
        <node TEXT="ERC667ReceiveAdapterMock.sol" />
        <node TEXT="ERC667ReceiveAdapter.sol" />
        <node TEXT="ERC667Receiver.sol" />
        <node TEXT="EtherReceiveAdapter.sol" />
        <node TEXT="ReceiveAdapterMock.sol" />
        <node TEXT="ReceiveAdapter.sol" />
        <node TEXT="ReceiveApprovalAdapter.sol" />
      </node>
      <node TEXT="token-derivatives">
        <node TEXT="BitcoinCash.sol" />
        <node TEXT="Dash.sol" />
        <node TEXT="Dogecoin.sol" />
        <node TEXT="ERC20Interface.sol" />
        <node TEXT="Loan.sol" />
        <node TEXT="Migrations.sol" />
        <node TEXT="Order.sol" />
        <node TEXT="ShortSell.sol" />
        <node TEXT="SimpleStorage.sol" />
        <node TEXT="Swap.sol" />
        <node TEXT="SwapToken.sol" />
        <node TEXT="TokenizedSwap.sol" />
      </node>
      <node TEXT="tokenized-assets">
        <node TEXT="swap">
          <node TEXT="Factory.sol" />
          <node TEXT="Swap.sol" />
        </node>
        <node TEXT="thirdpartyintegration">
          <node TEXT="AssetRequest.sol" />
          <node TEXT="Assets.sol" />
          <node TEXT="AssetToken.sol" />
          <node TEXT="AssetTypes.sol" />
          <node TEXT="MPAssetRequests.sol" />
          <node TEXT="REAssets.sol" />
          <node TEXT="weifund">
            <node TEXT="WFAssetInterface.sol" />
            <node TEXT="WFAssetProxyInterface.sol" />
            <node TEXT="WFAssetProxy.sol" />
            <node TEXT="WFAsset.sol" />
            <node TEXT="WFPlatformEmitter.sol" />
            <node TEXT="WFPlatformInterface.sol" />
            <node TEXT="WFPlatform.sol" />
          </node>
        </node>
      </node>
      <node TEXT="tokens">
        <node TEXT="ERC20">
          <node TEXT="ERC20BasicImpl.sol" />
          <node TEXT="ERC20Basic.sol" />
          <node TEXT="ERC20e.sol" />
          <node TEXT="ERC20Impl.sol" />
          <node TEXT="ERC20Interface.sol" />
          <node TEXT="ERC20.sol" />
          <node TEXT="ERC20Token.sol" />
          <node TEXT="IERC20Token.sol" />
        </node>
        <node TEXT="ERC667">
          <node TEXT="ApprovalNotifyToken.sol" />
          <node TEXT="ERC667Impl.sol" />
          <node TEXT="ERC667.sol" />
        </node>
        <node TEXT="minimetoken">
          <node TEXT="MiniMeΤοken.sol" />
        </node>
        <node TEXT="token-variants">
          <node TEXT="ExternalToken.sol" />
          <node TEXT="RoleBasedEventsToken.sol" />
          <node TEXT="SimpleToken.sol" />
          <node TEXT="TokenData.sol" />
          <node TEXT="TokenKYC.sol" />
        </node>
      </node>
    </node>
    <node TEXT="banking">
      <node TEXT="ATM.sol" />
      <node TEXT="ITokenBank.sol" />
      <node TEXT="TokenBank.sol" />
      <node TEXT="Treasury.sol" />
    </node>
    <node TEXT="client">
      <node TEXT="ClientContract.sol" />
      <node TEXT="ClientDetails.sol" />
      <node TEXT="ClientDirectory.sol" />
      <node TEXT="Client.sol" />
    </node>
    <node TEXT="infrastructure">
      <node TEXT="admin">
        <node TEXT="Administration.sol" />
        <node TEXT="AuthAdmin.sol" />
        <node TEXT="Roles.sol" />
      </node>
      <node TEXT="arrays">
        <node TEXT="AddressArrays.sol" />
        <node TEXT="Bytes32Arrays.sol" />
        <node TEXT="Uint256Arrays.sol" />
      </node>
      <node TEXT="helpers">
        <node TEXT="strings.sol" />
      </node>
      <node TEXT="ledger">
        <node TEXT="ITokenLedger.sol" />
        <node TEXT="TokenLedger.sol" />
      </node>
      <node TEXT="lock">
        <node TEXT="etherlock.sol" />
        <node TEXT="LICENSE"></node>
      </node>
      <node TEXT="registries">
        <node TEXT="PrivateServiceRegistry.sol" />
        <node TEXT="TokenRegistry.sol" />
        <node TEXT="TxRegister.sol" />
        <node TEXT="UserRegistry.sol" />
      </node>
      <node TEXT="safety">
        <node TEXT="CheckSign.sol" />
        <node TEXT="InputValidator.sol" />
      </node>
      <node TEXT="storage">
        <node TEXT="DataStore.sol" />
        <node TEXT="EternalStorage.sol" />
      </node>
      <node TEXT="upgradeable">
        <node TEXT="Forwardable.sol" />
        <node TEXT="OwnableUpgradeableImplementation">
          <node TEXT="IOwnableUpgradeableImplementation.sol" />
          <node TEXT="OwnableUpgradeableImplementation.sol" />
        </node>
        <node TEXT="SharedStorage.sol" />
        <node TEXT="UpgradeableImplementation.sol" />
        <node TEXT="UpgradeableProxy.sol" />
      </node>
    </node>
    <node TEXT="legacy">
      <node TEXT="Admin.sol" />
      <node TEXT="Backdoor.sol" />
      <node TEXT="Balances.sol" />
      <node TEXT="bancor_contracts">
        <node TEXT="BancorConverterExtensions.sol" />
        <node TEXT="BancorConverter.sol" />
        <node TEXT="BancorFormula.sol" />
        <node TEXT="BancorGasPriceLimit.sol" />
        <node TEXT="BancorPriceFloor.sol" />
        <node TEXT="BancorQuickConverter.sol" />
        <node TEXT="CrowdsaleController.sol" />
        <node TEXT="ERC20Token.sol" />
        <node TEXT="EtherToken.sol" />
        <node TEXT="helpers">
          <node TEXT="Migrations.sol" />
          <node TEXT="TestBancorFormula.sol" />
          <node TEXT="TestCrowdsaleController.sol" />
          <node TEXT="TestERC20Token.sol" />
          <node TEXT="TestUtils.sol" />
        </node>
        <node TEXT="interfaces">
          <node TEXT="IBancorConverterExtensions.sol" />
          <node TEXT="IBancorFormula.sol" />
          <node TEXT="IBancorGasPriceLimit.sol" />
          <node TEXT="IBancorQuickConverter.sol" />
          <node TEXT="IERC20Token.sol" />
          <node TEXT="IEtherToken.sol" />
          <node TEXT="IOwned.sol" />
          <node TEXT="ISmartToken.sol" />
          <node TEXT="ITokenConverter.sol" />
          <node TEXT="ITokenHolder.sol" />
        </node>
        <node TEXT="Managed.sol" />
        <node TEXT="Owned.sol" />
        <node TEXT="SmartTokenController.sol" />
        <node TEXT="SmartToken.sol" />
        <node TEXT="TokenHolder.sol" />
        <node TEXT="Utils.sol" />
      </node>
      <node TEXT="contracts.1">
        <node TEXT="ERC20.sol" />
        <node TEXT="Escapable.sol" />
        <node TEXT="helpers">
          <node TEXT="Migrations.sol" />
        </node>
        <node TEXT="Owned.sol" />
        <node TEXT="SafeMath.sol" />
        <node TEXT="test">
          <node TEXT="TestPayableEscapable.sol" />
          <node TEXT="TestToken.sol" />
        </node>
      </node>
      <node TEXT="controllers">
        <node TEXT="Owned.sol" />
      </node>
      <node TEXT="helpers">
        <node TEXT="Object.sol" />
        <node TEXT="Splitter.sol" />
      </node>
      <node TEXT="interfaces">
        <node TEXT="IBalances.sol" />
        <node TEXT="IERC23.sol" />
        <node TEXT="IKnownTokens.sol" />
        <node TEXT="IPriceDiscovery.sol" />
        <node TEXT="IRewardDAO.sol" />
      </node>
      <node TEXT="KnownTokens.sol" />
      <node TEXT="Migrations.sol" />
      <node TEXT="minime">
        <node TEXT="ApproveAndCallFallback.sol" />
        <node TEXT="Controlled.sol" />
        <node TEXT="MiniMeTokenFactory.sol" />
        <node TEXT="MiniMeToken.sol" />
        <node TEXT="TokenController.sol" />
      </node>
      <node TEXT="PriceDiscovery.sol" />
      <node TEXT="RewardDAO.sol" />
      <node TEXT="SafeMath.sol" />
      <node TEXT="TBK.sol" />
      <node TEXT="users">
      </node>
    </node>
    <node TEXT="Map2.mm"></node>
    <node TEXT="transaction">
      <node TEXT="channels">
        <node TEXT="Channels.sol" />
        <node TEXT="PaymentChannel.sol" />
        <node TEXT="PaymentForwarder.sol" />
      </node>
      <node TEXT="claims">
        <node TEXT="BalanceClaim.sol" />
        <node TEXT="Claim.sol" />
      </node>
      <node TEXT="dividend">
        <node TEXT="Dividend.sol" />
        <node TEXT="IDividend.sol" />
      </node>
      <node TEXT="escrow">
        <node TEXT="CuratedTransfers.sol" />
        <node TEXT="SafeRemotePurchase.sol" />
        <node TEXT="TokenTransferProxy.sol" />
        <node TEXT="TwoPhaseTransfers.sol" />
      </node>
      <node TEXT="relay">
        <node TEXT="deployer.sol" />
        <node TEXT="simple_storage.sol" />
        <node TEXT="testtoken.sol" />
        <node TEXT="transaction.sol" />
      </node>
      <node TEXT="vesting">
        <node TEXT="VestedPayment.sol" />
      </node>
    </node>
  </node>
  </map>
