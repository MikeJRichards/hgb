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


  //let hgb_token : actor {
  //      mint_transfer : shared (from: Principal, from_subaccount: ?Subaccount, to: Account, amount: Tokens, fee: ?Tokens, memo: ?Memo, created_at_time: ?Nat64) -> async Result<Nat, TransferError>;
	//	    icrc2_transfer_from : shared (caller: Principal, spender_subaccount: ?Blob, from :Account, to: Account, amount: Nat, fee: ?Nat, memo: ?Blob, created_at_time: ?Nat64) -> async (Nat, ICRC2.TransferFromError); 
	//} = actor ("wlksj-syaaa-aaaas-aaa4a-cai"); 

  let icrc7nft : actor {
        icrc7_transfer : shared (args : [ICRC7.TransferArg]) -> async [?ICRC7.TransferResult];
        icrc7_tokens_of: shared query (account: Account, prev: ?Nat, take: ?Nat) -> async [Nat];
	} = actor ("wmlu5-7aaaa-aaaas-aaa4q-cai");


 public shared ({ caller }) func swapLnftForHGB (amountOfTokens : Nat): async Result<(),Text>{
  //icrc7_tokens_of
  let exchangeAccount = {
    owner =Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
    subaccount =  null;
  };
  let owner = {
    owner = caller; 
    subaccount = null;
    };
  let token_ids : [Nat] =  await icrc7nft.icrc7_tokens_of(exchangeAccount, null, null);
  var transfers : [ICRC7.TransferArg] = [];
  for(i in Iter.range(0, amountOfTokens/1000)){
      let transfer : [ICRC7.TransferArg] = [{
          from_subaccount = null;
          to = owner;
          token_id = token_ids[i]; 
          memo = null;
          created_at_time = null;
      }];
      transfers := Array.append(transfers, transfer);
  };
  
  ignore await icrc7nft.icrc7_transfer(transfers);
  return #ok()  
 }
};
