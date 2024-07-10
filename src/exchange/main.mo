import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import ICRC7 "mo:icrc7-mo";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";

actor {
  public type Subaccount = Blob;
  public type Result<A,B> = Result.Result<A,B>;
  public type Account = { owner : Principal; subaccount : ?Subaccount };
  public type Tokens = Nat;
  public type Memo = Blob;
  public type DeduplicationError = {
    #TooOld;
    #Duplicate : { duplicate_of : Nat64 };
    #CreatedInFuture : { ledger_time : Nat64 };
  };

  public type CommonError = {
    #InsufficientFunds : { balance : Tokens };
    #BadFee : { expected_fee : Tokens };
    #TemporarilyUnavailable;
    #GenericError : { error_code : Nat; message : Text };
  };

  public type TransferError = DeduplicationError or CommonError or {
    #BadBurn : { min_burn_amount : Tokens };
  };



  let hgb_token : actor {
        icrc1_transfer: shared (from_subaccount : ?Subaccount, to : Account, amount : Tokens, fee : ?Tokens, memo : ?Memo, created_at_time : ?Nat64) -> async Result<Nat64, TransferError>;
	} = actor ("wlksj-syaaa-aaaas-aaa4a-cai"); 

  let icrc7nft : actor {
        icrc7_transfer : shared (args : [ICRC7.TransferArg]) -> async [?ICRC7.TransferResult];
        icrc7_tokens_of: shared query (account: Account, prev: ?Nat, take: ?Nat) -> async [Nat];
	} = actor ("wmlu5-7aaaa-aaaas-aaa4q-cai");

 let exchangeAccount = {
    owner =Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
    subaccount =  null;
  };

 public shared ({ caller }) func swapLnftForHGB (amountOfTokens : Nat): async Result<(),Text>{
  //icrc7_tokens_of
  let account : Account = {
    owner = caller; 
    subaccount = null;
    };
  let token_ids : [Nat] =  await icrc7nft.icrc7_tokens_of(exchangeAccount, null, null);
  var transfers : [ICRC7.TransferArg] = [];
  for(i in Iter.range(0, amountOfTokens/1000)){
      let transfer : [ICRC7.TransferArg] = [{
          from_subaccount = null;
          to = exchangeAccount;
          token_id = token_ids[i]; 
          memo = null;
          created_at_time = null;
      }];
      transfers := Array.append(transfers, transfer);
  };
  ignore await hgb_token.icrc1_transfer(null, exchangeAccount, amountOfTokens, null, null, null);
  ignore await icrc7nft.icrc7_transfer(transfers);
  return #ok()  
 };

 public shared ({ caller }) func swapHGBForLNFT (token_id : Nat): async Result<(),Text>{
  let owner = {
    owner = caller; 
    subaccount = null;
    };

  ignore await hgb_token.icrc1_transfer(null, owner, 1000, null, null, null);
let transfer : [ICRC7.TransferArg] = [{
          from_subaccount = null;
          to = exchangeAccount;
          token_id; 
          memo = null;
          created_at_time = null;
      }];
  
  ignore await icrc7nft.icrc7_transfer(transfer);
  return #ok()  
 }
};

