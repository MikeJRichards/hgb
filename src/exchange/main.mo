import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";

actor {
  public type Subaccount = Blob;
  public type Result<A,B> = Result.Result<A,B>;
  public type Account = { owner : Principal; subaccount : ?Subaccount };
  public type Tokens = Nat;
  public type Memo = Blob;
  public type TransferArgs = {
        from: Account;
        to: Account;
        token_ids: [Nat];
        memo: ?Blob;
        created_at_time: ?Nat64;
        is_atomic: ?Bool;
    };

    public type ApprovalArgs = {
        owner: Account;
        spender: Principal;
        token_ids: [Nat];
        expires_at: ?Nat64;
        memo: ?Blob;
        created_at_time: ?Nat64;
    };

    public type TransferError = {
        #Unauthorized: { token_ids: [Nat] };
        #TooOld;
        #CreatedInFuture: { ledger_time: Nat64 };
        #Duplicate: { duplicate_of: Nat };
        #TemporarilyUnavailable;
        #GenericError: { error_code: Nat; message: Text };
    };

    public type Error1 = {
        #InsufficientBalance;
        #InvalidAccount;
        #InvalidAmount;
        #Unauthorized;
        #PropertyNotFound;
        #TokenNotFound;
        #InvalidInput;
        #InternalError;
        #TokenAlreadyExists;
    };


    public type ApprovalError = {
        #Unauthorized;
        #TooOld;
        #TemporarilyUnavailable;
        #GenericError: { error_code: Nat; message: Text };
    };

    public type ComprehensiveError = {
      #Icrc1 : Error1;
      #Icrc7 : TransferError;
      #Icrc2 : ApprovalError;
    };

  let hgb : actor {
        icrc1_transfer: shared (Account, Account, Nat) -> async Result<(),Error1>;
        icrc1_balance_of: shared query (account: Account) -> async Nat;
        icrc1_decimals: shared query () -> async Nat8;
	} = actor ("wlksj-syaaa-aaaas-aaa4a-cai"); 

 let lnft : actor {
        icrc7_transfer: shared (args: TransferArgs) -> async Result<Nat, TransferError>;
        icrc7_tokens_of: shared query (account: Account) -> async [Nat];
        icrc7_balance_of: shared query (account: Account) -> async Nat;
        icrc7_approve: shared (args: ApprovalArgs) -> async Result<Nat, ApprovalError>;
	} = actor ("4kuta-kiaaa-aaaas-aabha-cai"); 

  let exchangeAccount = {
    owner = Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
    subaccount =  null;
  };

  public func getLNFTBalanceOfExchange (): async Nat {
    return await lnft.icrc7_balance_of(exchangeAccount);
  };

  public shared ({caller}) func getLNFTBalanceOfUser (): async Nat {
    let user : Account = {
      owner = caller;
      subaccount = null;
    };
    return await lnft.icrc7_balance_of(user);
  };

   public shared ({caller}) func getLNFTokenseOfUser (): async [Nat] {
    let user : Account = {
      owner = caller;
      subaccount = null;
    };
    return await lnft.icrc7_tokens_of(user);
  };

  public func getHGBBalnaceOfExchange (): async Nat {
    return await hgb.icrc1_balance_of(exchangeAccount);
  };

  public shared ({caller}) func getHGBBalnaceOfUser (): async Nat {
    let user : Account = {
      owner = caller;
      subaccount = null;
    };
    return await hgb.icrc1_balance_of(user);
  };
    
  public shared ({ caller }) func get_principal (): async Principal {
        return caller;
  };

 public shared ({ caller }) func userSwapsLnftForHGB (nOfLNFT : Nat): async Result<Nat, ComprehensiveError>{
    let userAccount : Account = {
      owner = caller;
      subaccount = null;
    };

    var tokenIds = await lnft.icrc7_tokens_of(userAccount);
    if(tokenIds.size() < nOfLNFT){
      return #err(#Icrc1(#InvalidAmount))
    };

    let decimals = await hgb.icrc1_decimals();
    let aHGB = Nat.pow(10, Nat8.toNat(decimals));
    let oneLNFT = Nat.mul(aHGB, 1000);
    let amountOfHGB = Nat.mul(nOfLNFT, oneLNFT);
    let exchangeBalance = await hgb.icrc1_balance_of(exchangeAccount);
    if(exchangeBalance < amountOfHGB){
      return #err(#Icrc1(#InsufficientBalance));
    };
    let transferHGB = await hgb.icrc1_transfer(exchangeAccount, userAccount, amountOfHGB);
    switch(transferHGB){
      case(#ok){};
      case(#err error){return #err(#Icrc1(error))};
    };

    tokenIds := Array.take(tokenIds, nOfLNFT);
    let approval : ApprovalArgs = {
        owner = {owner = caller; subaccount = null};
        spender = Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
        token_ids = tokenIds;
        expires_at = null;
        memo = null;
        created_at_time = null;
    };
    let approvalResult = await lnft.icrc7_approve(approval);
    switch(approvalResult){
      case(#ok _){      };
      case (#err error){return #err(#Icrc2(error))}
    };


    let transferArgs : TransferArgs = {
      from = userAccount;
      to = exchangeAccount;
      token_ids = tokenIds;
      memo = null;
      created_at_time = null;
      is_atomic = null;
    };
    let transferLNFT = await lnft.icrc7_transfer(transferArgs);
    switch(transferLNFT){
      case(#ok result){return #ok(result)};
      case(#err error){return #err(#Icrc7(error))};//return #err(error)};
    };
 };




 public shared ({ caller }) func swapHGBForLNFT (amountOfHGB : Nat): async Result<Nat, ComprehensiveError>{
    let userAccount : Account = {
      owner = caller;
      subaccount = null;
    };

    let decimals = await hgb.icrc1_decimals();
    let aHGB = Nat.pow(10, Nat8.toNat(decimals));
    let oneLNFTInHGB = Nat.mul(aHGB, 1000);
    if(Nat.notEqual(Nat.rem(amountOfHGB, oneLNFTInHGB), 0)){
      return #err(#Icrc1(#InvalidAmount))
    };

    let balance = await hgb.icrc1_balance_of(userAccount);
    if(Nat.greaterOrEqual(amountOfHGB, balance)){
      return #err(#Icrc1(#InsufficientBalance));
    };

    let nOfLNFT = Nat.div(amountOfHGB, oneLNFTInHGB);
    var tokenIds = await lnft.icrc7_tokens_of(exchangeAccount);
    if(tokenIds.size() < nOfLNFT){
      return #err(#Icrc1(#InvalidAmount))
    };

    let transferHGB = await hgb.icrc1_transfer(userAccount, exchangeAccount, amountOfHGB);
    switch(transferHGB){
      case(#ok){};
      case(#err error){return #err(#Icrc1(error))};
    };

    tokenIds := Array.take(tokenIds, nOfLNFT);
    let transferArgs : TransferArgs = {
      from = exchangeAccount;
      to = userAccount;
      token_ids = tokenIds;
      memo = null;
      created_at_time = null;
      is_atomic = null;
    };
    let transferLNFT = await lnft.icrc7_transfer(transferArgs);
    switch(transferLNFT){
      case(#ok result){return #ok(result)};
      case(#err error){return #err(#Icrc7(error))};
    }; 
 }
};

