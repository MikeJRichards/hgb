import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Nat8 "mo:base/Nat8";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Types "./../property_database/types";

actor HGBToken {
    public type TokenDetails = Types.TokenDetails;
    public type Result<A,B> = Result.Result<A,B>; 
    public type Balance = Types.Balance;
    public type Hash = Hash.Hash;
    public type Subaccount = Types.Subaccount;
    public type Account = Types.Account;
    public type TokenArgs = Types.TokenArgs;
    public type Error = Types.Error;
    public type Value = Types.Value;
    public type Allowance = Types.Allowance;
    public type HashMap<A,B> = HashMap.HashMap<A,B>;
    public type Transaction = Types.TransactionICRC3;

    func accountEqual(x: Account, y: Account): Bool { x.owner == y.owner and x.subaccount == y.subaccount };
    func accountHash(x: Account): Hash { Principal.hash(x.owner) };
    func hash(n : Nat) : Nat32 { Blob.hash(Text.encodeUtf8(Nat.toText(n))); };

    let balances : HashMap<Account, Balance> = HashMap.HashMap<Account, Balance>(0, accountEqual, accountHash);
    let allowances : HashMap<Nat, Allowance> = HashMap.HashMap<Nat, Allowance>(0, Nat.equal, hash);
    let transactionLog : HashMap<Nat, Transaction> = HashMap.HashMap<Nat,Transaction>(0, Nat.equal, hash);
    
    stable var allowanceId : Nat = 0;
    stable var nextTransactionId: Nat = 0;

    stable var totalSupply: Balance = 0;
    stable var collateral: Balance = 0;

    stable var collateralAccount: Account = {
        owner = Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
        subaccount = null;
    };

    let mintingAccount: Account = {
        owner = Principal.fromText("xgewh-5qaaa-aaaas-aaa3q-cai");
        subaccount = null;
    };

    var tokenDetails: TokenDetails = {
        name = "HGB Token";
        symbol = "HGB";
        decimals = 8;
        transfer_fee = 10000;
        logo_url = "https://5v4ax-jqaaa-aaaas-aabdq-cai.icp0.io/icon_logo_trans.png";
    };

    let HGBToken: TokenArgs = {
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

    func logTransaction(from: ?Account, to: ?Account, amount: Balance) {
        let transactionId = nextTransactionId;
        nextTransactionId += 1;
        transactionLog.put(transactionId, { from; to; amount; timestamp = Time.now() });
    };

    public shared ({ caller }) func get_principal (): async Principal { caller };

    public query func icrc1_name(): async Text { HGBToken.init.tokenDetails.name };

    public query func icrc1_symbol(): async Text { HGBToken.init.tokenDetails.symbol };

    public query func icrc1_decimals(): async Nat8 { HGBToken.init.tokenDetails.decimals };

    public query func icrc1_total_supply(): async Balance { totalSupply };

    public query func icrc1_transfer_fee(): async Balance { HGBToken.init.tokenDetails.transfer_fee };

    public query func icrc1_metadata(): async [(Text, Value)] {
        [("icrc1:name", #Text(HGBToken.init.tokenDetails.name)), 
         ("icrc1:symbol", #Text(HGBToken.init.tokenDetails.symbol)),
         ("icrc1:decimals", #Nat(Nat8.toNat(HGBToken.init.tokenDetails.decimals))),
         ("icrc1:fee", #Nat(HGBToken.init.tokenDetails.transfer_fee)),
         ("icrc1:logo", #Text(HGBToken.init.tokenDetails.logo_url))]
    };

    public shared query func icrc1_balance_of(account: Account): async Balance {
        switch (balances.get(account)) { 
            case (null) { 
                return 0 
            }; 
            case (?balance) { 
                return balance 
            };
        };
    };

    public shared ({ caller }) func icrc1_transfer(from: Account, to: Account, amount: Balance): async Result<(), Error> {
        if (Principal.notEqual(caller, from.owner)) { 
            return #err(#Unauthorized) 
        };

        if (amount <= 0 and amount < tokenDetails.transfer_fee) { 
            return #err(#InvalidAmount) 
        };

        switch (balances.get(from)) {
            case (null) { 
                return #err(#InsufficientBalance) 
            };
            case (?balance) {
                if (balance >= amount) {
                    let newBalanceFrom = Nat.sub(balance, amount);
                    let newBalanceTo = switch (balances.get(to)) { 
                        case (null) { 
                            amount 
                        }; 
                        case (?balanceTo) { 
                            Nat.add(balanceTo, amount) 
                        } 
                    };
                    balances.put(from, newBalanceFrom);
                    balances.put(to, newBalanceTo);
                    logTransaction(?from, ?to, amount);
                    return #ok();
                } 
                else { 
                    return #err(#InsufficientBalance) 
                };
            };
        };
    };

    public shared ({ caller }) func icrc1_mint(account: Account, amount: Balance): async Result<(), Error> {
        if (Principal.notEqual(caller, mintingAccount.owner)) { 
            return #err(#Unauthorized) 
        };
        
        if (amount <= 0) { 
            return #err(#InvalidAmount) 
        };

        let newBalance = switch (balances.get(account)) { 
            case (null) { 
                amount 
            }; 
            case (?balance) { 
                balance + amount 
            } 
        };

        balances.put(account, newBalance);
        totalSupply += amount;
        logTransaction(null, ?account, amount);
        return #ok();
    };

    public shared ({caller}) func icrc1_burn(account: Account, amount: Balance): async Result<(), Error> {
        if (Principal.notEqual(caller, account.owner)) { 
            return #err(#Unauthorized) 
        };

        if (amount <= 0 and amount < tokenDetails.transfer_fee) { 
            return #err(#InvalidAmount) 
        };

        switch (balances.get(account)) {
            case (null) { 
                return #err(#InsufficientBalance) 
            };
            case (?balance) {
                if (balance >= amount) {
                    balances.put(account, balance - amount);
                    totalSupply -= amount;
                    logTransaction(?account, null, amount);
                    return #ok();
                } 
                else { 
                    return #err(#InsufficientBalance) 
                };
            };
        };
    };

    // ICRC-2: Batch Transfer Function
    public shared func icrc2_batch_transfer(transfers: [(Account, Account, Balance)]): async Result<(), Error> {
        for ((from, to, amount) in transfers.vals()) {
            let transferResult = await icrc1_transfer(from, to, amount);
            switch (transferResult) { 
                case (#err(error)) { 
                    return #err(error) 
                }; 
                case (#ok) {} 
            }
        };
        return #ok();
    };

    // ICRC-1: Approve and Transfer From Functions
      public shared ({ caller }) func icrc1_approve(owner: Account, spender: Account, amount: Balance): async Result<(), Error> {
        if (Principal.notEqual(caller, owner.owner)) { 
            return #err(#Unauthorized) 
        };
        
        if (amount <= 0) { 
            return #err(#InvalidAmount) 
        };

        let newAllowance: Allowance = { 
            owner; 
            spender; 
            amount 
        };

        allowanceId += 1;
        allowances.put(allowanceId, newAllowance);
        return #ok();
    };


   public shared ({ caller }) func icrc1_transfer_from(from: Account, to: Account, amount: Balance): async Result<(), Error> {
    if (amount <= 0) { 
        return #err(#InvalidAmount) 
    };

    let callerAccount: Account = { 
        owner = caller; 
        subaccount = null 
    };

    // Iterate over allowances to find the matching one
    var allowanceKey: ?Nat = null;
    for ((key, allowance) in allowances.entries()) {
        if (allowance.owner == from and allowance.spender == callerAccount) {
            allowanceKey := ?key;
        }
    };

    let allowanceId : Nat = switch(allowanceKey){
        case(? key){
            key
        };
        case(null){
            return #err(#InvalidAccount);
        };
    };

    // Check if a matching allowance was found
    switch (allowances.get(allowanceId)) {
        case (null) { 
            return #err(#Unauthorized) 
        };
        case (?allowance) {
            if (allowance.amount < amount) { 
                return #err(#InsufficientBalance) 
            };

            let transferResult = await icrc1_transfer(from, to, amount);
            switch (transferResult) {
                case (#err(error)) { 
                    return #err(error) 
                };
                case (#ok(())) {
                    let newAllowance: Allowance = { 
                        owner = allowance.owner; 
                        spender = allowance.spender; 
                        amount = allowance.amount - amount 
                    };

                    allowances.put(allowanceId, newAllowance);
                    logTransaction(?from, ?to, amount);
                    return #ok();
                }
            }
        }
    }
};

 // ICRC-5: Redeem Function
    public shared ({ caller }) func icrc5_redeem(amount: Balance): async Result<(), Error> {
        if (Principal.notEqual(caller, collateralAccount.owner)) { 
            return #err(#Unauthorized) 
        };

        if (amount > collateral or amount <= 0) { 
            return #err(#InsufficientBalance) 
        };

        collateral -= amount;
        let userAccount :Account = {
            owner = caller; 
            subaccount = null
        };

        let balance = switch (balances.get(userAccount)) { 
            case (null) { 
                amount 
            }; 
            case (?existingBalance) { 
                existingBalance + amount 
            } 
        };

        balances.put(userAccount, balance);
        logTransaction(?collateralAccount, ?userAccount, amount);
        return #ok();
    };

    // Function to add collateral
    public shared ({ caller }) func add_collateral(amount: Balance): async Result<(), Error> {
        if (Principal.notEqual(caller, collateralAccount.owner)) { 
            return #err(#Unauthorized) 
        };

        if (amount <= 0) { 
            return #err(#InvalidAmount) 
        };

        collateral += amount;
        return #ok();
    };

    // ICRC-3: Query Transaction Log
    public query func icrc3_get_transaction(transactionId: Nat): async Result<Transaction, Error> {
        switch (transactionLog.get(transactionId)) {
            case (null) { 
                return #err(#InvalidInput) 
            };
            case (?transaction) { 
                return #ok(transaction) 
            };
        }
    };

    public query func icrc3_get_transactions(): async [(Nat, Transaction)] {
        Iter.toArray(transactionLog.entries());
    };

    // System Upgrade Functions
    stable var stableBalances: [(Account, Balance)] = [];
    stable var stableAllowances: [(Nat, Allowance)] = [];
    stable var stableTransactions: [(Nat, Transaction)] = [];

    system func preupgrade() {
        stableBalances := Iter.toArray(balances.entries());
        stableAllowances := Iter.toArray(allowances.entries());
        stableTransactions := Iter.toArray(transactionLog.entries());
    };

    system func postupgrade() {
        for ((account, balance) in stableBalances.vals()) { 
            balances.put(account, balance) 
        };

        for ((allowanceId, allowance) in stableAllowances.vals()) { 
            allowances.put(allowanceId, allowance) 
        };

        for ((transactionId, transaction) in stableTransactions.vals()) { 
            transactionLog.put(transactionId, transaction) 
        };
    };
};
