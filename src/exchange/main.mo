import Principal "mo:base/Principal";

actor {
  let hgb_token : actor {
        mint_transfer : shared (from: Principal, from_subaccount: ?Subaccount, to: Account, amount: Tokens, fee: ?Tokens, memo: ?Memo, created_at_time: ?Nat64) -> async Result<Nat, TransferError>;
		    icrc2_transfer_from : shared (caller: Principal, spender_subaccount: ?Blob, from :Account, to: Account, amount: Nat, fee: ?Nat, memo: ?Blob, created_at_time: ?Nat64) -> async (Nat, ICRC2.TransferFromError); 
	} = actor ("wlksj-syaaa-aaaas-aaa4a-cai"); 

  let icrc7nft : actor {
		icrcX_mint : shared (tokens: ICRC7.SetNFTRequest) -> async [ICRC7.SetNFTResult]; 
        assign: shared (token_id: Nat, account : ICRC7.Account) -> async Nat;
        icrc7_transfer : shared (args : [ICRC7.TransferArg]) -> async [?ICRC7.TransferResult];
        icrc7_total_supply: shared query ()-> async Nat;
        icrc7_tokens_of: shared query (account: Account, prev: ?Nat, take: ?Nat) -> 
	} = actor ("wxoiy-fyaaa-aaaas-aaa6a-cai");


  public shared (caller) func swapLnftForHGB (): async Result<(),Text>{
    //icrc7_tokens_of
    
    let transfer : ICRC7.TransferArg = {
            from_subaccount = null;
            to = exchangeCanister;
            token_id = 1; 
            memo = null;
            created_at_time = ?Nat64.fromIntWrap(Time.now());
        };
//
       // ignore await icrc7nft.icrc7_transfer([transfer]);
    
    icrc7nft.icrc7_transfer
  }
};
