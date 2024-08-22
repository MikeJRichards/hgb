import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Hash "mo:base/Hash";

module {
    public type TokenId = Nat;
    public type Attribute = { key: Text; value: Text };
    public type Result<A, B> = Result.Result<A, B>;
    public type Hash = Hash.Hash;
    public type Balance = Nat;
    public type Subaccount = ?Blob;
    public type TxIndex = Nat;
    public type Timestamp = Nat64;
    public type Memo = Blob;
    public type Tokens = Nat;
    public type Value = { #Nat : Nat; #Int : Int; #Blob : Blob; #Text : Text };
    
    public type Property = {
      propertyId: Nat;
      name: Text;
      addressLine1: Text;
      postcode: Text;
      purchasePrice: Nat;
      currentValue: Nat;
      loanAmount: Nat;
      lNftN : [Nat];
    };
    
    public type Account = {
         owner: Principal;
         subaccount: ?Blob;
     };
    
     public type Metadata = {
         name: Text;
        description: Text;
        image: Text; // URL to the image
        creator: Principal;
        creationDate: Int;
        attributes: [Attribute];
    };

    public type Token = {
        id: TokenId;
        owner: Account;
        metadata: Metadata;
    };

    public type TokenDetails = {
        name: Text;
        symbol: Text;
        decimals : Nat8; 
        transfer_fee : Nat;
        logo_url: Text;
    };

    public type TokenArgs = {
        init : { 
          initial_mints : [
            { 
                account : Account; 
                amount : Nat;
            }
          ]; 
          minting_account : Account; 
          tokenDetails : TokenDetails
    };
  };

    public type Transaction = {
        id: Nat;
        action: TransactionTypes;
        tokenId: TokenId;
        from: ?Account;
        to: ?Account;
        timestamp: Int;
    };

    // ICRC3 Transaction Log
    public type TransactionICRC3 = {
        from: ?Account;
        to: ?Account;
        amount: Balance;
        timestamp: Int;
    };

    public type TransactionTypes = {
        #Mint;
        #Transfer;
        #Burn;
    };

    public type TransferArgs = {
        from: Account;
        to: Account;
        token_ids: [TokenId];
        memo: ?Blob;
        created_at_time: ?Nat64;
        is_atomic: ?Bool;
    };

    public type TransferArgs1 = {
        to : Account;
        fee : ?Balance;
        memo : ?Blob;
        from_subaccount : ?Subaccount;
        created_at_time : ?Nat64;
        amount : Balance;
    };

    public type Approval = {
        owner: Account;
        approved: Account;
        tokenId: TokenId;
    };

    public type Allowance = {
        owner: Account;
        spender: Account;
        amount: Balance;
    };

    public type ApprovalArgs = {
        owner : Account;
        spender: Principal;
        token_ids: [TokenId];
        expires_at: ?Nat64;
        memo: ?Blob;
        created_at_time: ?Nat64;
    };


    public type DepositArgs = { 
        fee : Nat; 
        token : Text; 
        amount : Nat 
    };

    public type SwapArgs = {
        amountIn : Text;
        zeroForOne : Bool;
        amountOutMinimum : Text;
    };

    public type WithdrawArgs = { 
        fee : Nat; 
        token : Text; 
        amount : Nat 
    };

    public type Result1 = { 
        #ok : Nat; 
        #err : Error1 
    };

    public type TransferResult = { 
        #Ok : TxIndex; 
        #Err : TransferError 
    };

    public type Error = {
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

    public type Error1 = {
        #CommonError;
        #InternalError : Text;
        #UnsupportedToken : Text;
        #InsufficientFunds;
    };

    public type TransferError = {
        #Unauthorized: { token_ids: [TokenId] };
        #TooOld;
        #CreatedInFuture: { ledger_time: Nat64 };
        #Duplicate: { duplicate_of: Nat };
        #TemporarilyUnavailable;
        #GenericError: { error_code: Nat; message: Text };
    };

    public type ApprovalError = {
        #Unauthorized;
        #TooOld;
        #TemporarilyUnavailable;
        #GenericError: { error_code: Nat; message: Text };
    };

    public type ComprehensiveError = {
      #Icrc1 : Error;
      #Icrc7 : TransferError;
      #Icrc2 : ApprovalError;
      #Swap : Error1;
    };
}