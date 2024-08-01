import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Nat8 "mo:base/Nat8";
import Types "./../property_database/types";

actor HGBToken {
    type TokenDetails = Types.TokenDetails;
    type Result <A,B> = Result.Result<A,B>; 
    type Balance = Types.Balance;
    type Hash = Hash.Hash;
    public type Subaccount = Types.Subaccount;
    type Account = Types.Account;
    public type TokenArgs = Types.TokenArgs;
    type Error = Types.Error;
    public type Value = Types.Value;

    func accountEqual(x: Account, y: Account): Bool {
      if(x.owner == y.owner and x.subaccount == y.subaccount){
        return true;
      };
      return false;
    };

    func accountHash (x:Account): Hash{
      return Principal.hash(x.owner);
    };

    let balances = HashMap.HashMap<Account, Balance>(0, accountEqual, accountHash);

    var tokenDetails: TokenDetails = {
        name = "HGB Token";
        symbol = "HGB";
        decimals = 8;
        transfer_fee = 10000;
        logo_url = "https://5v4ax-jqaaa-aaaas-aabdq-cai.icp0.io/icon_logo_trans.png";
    };

    let mintingAccount : Account = {
      owner = Principal.fromText("xgewh-5qaaa-aaaas-aaa3q-cai");
      subaccount = null;
    };
    
    let HGBToken : TokenArgs = {
      init = { 
        initial_mints = [
          { 
            account = mintingAccount;
            amount = 10000;
          }
        ]; 
        minting_account = mintingAccount;
        tokenDetails;
      };
    };

    public shared ({ caller }) func get_principal (): async Principal {
        return caller;
    };

    public query func icrc1_name(): async Text {
        return HGBToken.init.tokenDetails.name;
    };

    public query func icrc1_symbol(): async Text {
        return HGBToken.init.tokenDetails.symbol;
    };

    public query func icrc1_decimals(): async Nat8 {
        return HGBToken.init.tokenDetails.decimals;
    };

    public query func icrc1_total_supply(): async Balance {
        var total_supply : Balance = 0;
        for(balance in balances.vals()){
            total_supply += balance;
        };
        return total_supply;
    };
    
    public query func icrc1_transfer_fee(): async Balance {
        return HGBToken.init.tokenDetails.transfer_fee;
    };

    public query func icrc1_metadata() : async [(Text, Value)] {
        [
          ("icrc1:name", #Text(HGBToken.init.tokenDetails.name)),
          ("icrc1:symbol", #Text(HGBToken.init.tokenDetails.symbol)),
          ("icrc1:decimals", #Nat(Nat8.toNat(HGBToken.init.tokenDetails.decimals))),
          ("icrc1:fee", #Nat(HGBToken.init.tokenDetails.transfer_fee)),
          ("icrc1:logo", #Text(HGBToken.init.tokenDetails.logo_url))
        ];
    };

    public shared query func icrc1_balance_of(account: Account): async Balance {
        switch (balances.get(account)) {
            case (null) { return 0 };
            case (?balance) { return balance};
        }
    };

    public func icrc1_transfer(from: Account, to: Account, amount: Balance): async Result<(),Error> {
        if(amount < 0 + tokenDetails.transfer_fee){
            return #err(#InvalidAmount);
        };
        switch (balances.get(from)) {
            case (null) { return #err(#InsufficientBalance) };
            case (?balance) {
                if (balance >= amount) {
                    let newBalanceFrom = Nat.sub(balance, amount);
                    let newBalanceTo = switch (balances.get(to)) {
                        case (null) { amount };
                        case (?balanceTo) { Nat.add(balanceTo,amount) };
                    };
                    balances.put(from, newBalanceFrom);
                    balances.put(to, newBalanceTo);
                    return #ok();
                } else {
                    return #err(#InsufficientBalance);
                }
            };
        }
    };

    public shared ({ caller }) func icrc1_mint(account: Account, amount: Balance): async Result<(),Error> {
        if(Principal.notEqual(caller, mintingAccount.owner)){
            return #err(#Unauthorized);
        };
        if(amount < 0){
            return #err(#InvalidAmount);
        };
        
        let newBalance = switch (balances.get(account)) {
            case (null) { amount };
            case (?balance) { balance + amount };
        };
        balances.put(account, newBalance);
        return #ok();
    };

    public func icrc1_burn(account: Account, amount: Balance): async Result<(),Error> {
        if(amount < 0 + tokenDetails.transfer_fee){
            return #err(#InvalidAmount);
        };

        switch (balances.get(account)) {
            case (null) { return #err(#InsufficientBalance)};
            case (?balance) {
                if (balance >= amount) {
                    balances.put(account, balance - amount);
                };
                return #ok();
            };
        }
    };


   //     stable var tokens : [Nat] =[];
   //     stable var owners : [Account] =[]; 
   // system func preupgrade() {
   //     tokens := Iter.toArray(balances.vals());
   //     owners := Iter.toArray(balances.keys());
   // };
//
   // system func postupgrade() {
   //     for (i in tokens.vals()) {
   //         balances.put(owners[i-1], tokens[i-1]);
   //     };
   // };
};
