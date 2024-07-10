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
		    icrcX_mint : shared (tokens: ICRC7.SetNFTRequest) -> async [ICRC7.SetNFTResult]; 
        assign: shared (token_id: Nat, account : ICRC7.Account) -> async Nat;
        icrc7_transfer : shared (args : [ICRC7.TransferArg]) -> async [?ICRC7.TransferResult];
        icrc7_total_supply: shared query ()-> async Nat;
        icrc7_tokens_of: shared query (account: Account, prev: ?Nat, take: ?Nat) -> async [Nat];
	} = actor ("wxoiy-fyaaa-aaaas-aaa6a-cai");


 // public shared ({ caller }) func swapLnftForHGB (amountOfTokens : Nat): async Result<(),Text>{
  //  //icrc7_tokens_of
  //  let exchangeAccount = {
  //    owner =Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
  //    subaccount =  null;
  //  };
  //  let token_ids : [Nat] =  await icrc7nft.icrc7_tokens_of(exchangeAccount, null, null);
  //  let transfers : [ICRC7.TransferArg] = [];
  //  for(i in Iter.range(0, amountOfTokens/1000)){
  //      let transfer : ICRC7.TransferArg = {
  //          from_subaccount = null;
  //          to = {owner = caller; subaccount = null;};
  //          token_id = token_ids[i]; 
  //          memo = null;
  //          created_at_time = ?Nat64.fromIntWrap(Time.now());
  //      };
  //      Array.append(transfers, transfer);
  //      
  //  };
  //  ignore await icrc7nft.icrc7_transfer(transfers);
  //  
  //  icrc7nft.icrc7_transfer
 // }
};
