pragma solidity ^0.4.13;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "https://github.com/DecentralizedDerivatives/Deriveth/Sf.sol";

ontract Swap is usingOraclize{
  enum SwapState {created,open,started,ready,over,ended}
  SwapState public currentState;
  address public long_party;
  address public short_party;
  uint public notional;
  uint public lmargin;
  uint public smargin;
  string public url;
  uint public duration;
  uint public startValue;
  uint public endValue;
  bool public cancel_long;
  bool public cancel_short;
  bool public paid_short;
  bool public paid_long;
  uint public share_long;
  uint public share_short;
  uint256 public s_premium; //short premium (bonus to short side in wei, input in finney (1/1000 of ether))
  uint256 public l_premium; //long premium (bonus to long side in wei, input in finney (1/1000 of ether))
  bytes32 sId;
  bytes32 eId;
  bool long;
  uint obal;
  address party;
  event Print(string _name, uint _value);

modifier onlyState(SwapState expectedState) {require(expectedState == currentState);_;}

  function Swap(address _cpty1){
      party = _cpty1;
      currentState = SwapState.created;
  }

 
  function CreateSwap(string _url, uint _duration, uint _lmargin, uint _smargin, uint _notional, bool _long, uint _l_premium, uint _s_premium) payable {
      require (msg.sender == party);
      url = _url;
      notional = Sf.mul(_notional,1e18);
      l_premium = Sf.mul(_l_premium,1e15);
      s_premium = Sf.mul(_s_premium,1e15);
      long = _long;
      duration = _duration;
      lmargin = Sf.mul(_lmargin,1e18);
      smargin = Sf.mul(_smargin,1e18);
      if (long){long_party = msg.sender;
        require(msg.value == Sf.add(l_premium,lmargin));
      }
      else {short_party = msg.sender;
        require(msg.value == Sf.add(s_premium,smargin));
      }
      currentState = SwapState.open;
      Print ('Contract Balance',this.balance);
  }

  function EnterSwap(string _url,uint _lmargin,uint _smargin, uint _notional, bool _long, uint _duration, uint256 _l_premium, uint256 _s_premium) public onlyState(SwapState.open) payable {
      require(sha3(_url) == sha3(url) && _long != long && notional == Sf.mul(_notional,1e18) && _duration == duration);
      if (long) {
      short_party = msg.sender;
      require(msg.value >= Sf.add(s_premium,smargin));
      require(Sf.add(lmargin,l_premium) >= Sf.add(Sf.mul(_l_premium,1e15),Sf.mul(_lmargin,1e18)));
      }
      else {long_party = msg.sender;
      require(msg.value >=Sf.add(l_premium,lmargin));
      require(Sf.add(smargin,s_premium) >= Sf.add(Sf.mul(_s_premium,1e15),Sf.mul(_smargin,1e18)));
      }
      obal = Sf.sub(this.balance,Sf.add(l_premium,s_premium));
      Print ('Contract Balance',this.balance);
      sId = oraclize_query("URL",url);
      eId = oraclize_query(duration,"URL",url);
      currentState = SwapState.started;
      Print ('Contract Balance',this.balance);
  }

    function __callback(bytes32 _oraclizeID, string _result) {
      require(msg.sender == oraclize_cbAddress());
      if (_oraclizeID == sId){
        startValue = parseInt(_result,3);
      }
      else if (_oraclizeID == eId){
        endValue = parseInt(_result,3);
        currentState = SwapState.ready;
      }
    }
  

  function Calculate() onlyState(SwapState.ready){
    uint p1=Sf.div(Sf.mul(1000,endValue),startValue);
    uint adj_bal = Sf.sub(this.balance,Sf.add(l_premium,s_premium));
    Print ("adj_balance",adj_bal);
    lmargin = Sf.div(Sf.mul(adj_bal,lmargin),obal);
    smargin = Sf.div(Sf.mul(adj_bal,smargin),obal);
    notional = Sf.div(Sf.mul(adj_bal,notional),obal);
    Print("p1",p1);
    if (p1 == 1000){
            share_long = s_premium + lmargin;
            share_short = l_premium + smargin;
        }
        else if (p1<1000){
              if(Sf.mul(Sf.div(notional,1000),Sf.sub(1000,p1))>lmargin){share_long = s_premium; share_short = adj_bal + l_premium;}
              else {
                share_short = Sf.add(Sf.add(l_premium,smargin),Sf.div(Sf.mul(Sf.sub(1000,p1),notional),1000));
                share_long = this.balance -  share_short;
              }
          }
          
        else if (p1 > 1000){
               if(Sf.mul(Sf.div(notional,1000),Sf.sub(p1,1000))>smargin){share_short = l_premium; share_long =adj_bal + s_premium;}
               else {
                  share_long = Sf.add(Sf.add(s_premium,lmargin),Sf.div(Sf.mul(Sf.sub(p1,1000),notional),1000));
                  share_short = this.balance - share_long;
               }
          }
    currentState = SwapState.over;    
    Print ('Share Short',share_short);
    Print ('Share Long',share_long);
    }
  function PaySwap()onlyState(SwapState.over){
  if (msg.sender == long_party && paid_long == false){
        paid_long = true;
        long_party.transfer(share_long);
        cancel_long = false;
    }
    else if (msg.sender == short_party && paid_short == false){
        paid_short = true;
        short_party.transfer(share_short);
        cancel_short = false;
    }
    if (paid_long && paid_short){currentState = SwapState.ended;}

    Print ('Contract Balance',this.balance);
  }

  function Exit() public {
    require(currentState != SwapState.ended);
    require(currentState != SwapState.created);
    if (currentState == SwapState.open && msg.sender == party) {
        lmargin = 0;
        smargin = 0;
        notional = 0;
        long = false;
        duration = 0;
        sId = 0;
        url = '';
        short_party = 0;
        long_party = 0;
        s_premium = 0;
        l_premium = 0;
        currentState = SwapState.created;
        msg.sender.transfer(this.balance);
    }

  else{
    if (msg.sender == long_party && paid_long == false){cancel_long = true;}
    else if (msg.sender == short_party && paid_short == false){cancel_short = true;}
    if (cancel_long && cancel_short){
        uint adj_bal = Sf.sub(this.balance,Sf.add(l_premium,s_premium));
        smargin = Sf.div(Sf.mul(adj_bal,smargin),(notional));
        short_party.transfer(Sf.add(smargin,s_premium));
        long_party.transfer(this.balance);
        currentState = SwapState.ended;
      }
    }
  }
}
