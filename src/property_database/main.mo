import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Types "types";


actor {
    public type Error1 = Types.Error1;
    public type Subaccount = Types.Subaccount;
    public type Account = Types.Account;
    public type Tokens = Types.Tokens;
    public type Memo = Types.Memo;
    public type Result<A,B> = Result.Result<A,B>;
    public type Property = Types.Property;
    public type Balance = Nat;
    public type TxIndex = Nat;
    public type Timestamp = Nat64;
    public type ComprehensiveError = Types.ComprehensiveError;
    public type TransferError = Types.TransferError;
    public type DepositArgs = Types.DepositArgs;
    public type SwapArgs = Types.SwapArgs;
    public type WithdrawArgs = Types.WithdrawArgs;
    public type Result1 = Types.Result1;
    public type Error = Types.Error;
    public type TransferResult = Types.TransferResult;
    public type TransferArgs = Types.TransferArgs1;
    
    let hgb : actor {
        icrc1_mint: (Account, Balance) -> async Result<(), Error1>;
        icrc1_transfer: shared (Account, Account, Balance) -> async Result<(),Error1>;
        icrc1_decimals: shared query () -> async Nat8;
        icrc1_balance_of: shared query (Account) -> async Balance; 
    } = actor("wlksj-syaaa-aaaas-aaa4a-cai");

    let lnft : actor {
        icrc7_mint_batch(number : Nat): async Result<[Nat], Error1>
    } = actor("4kuta-kiaaa-aaaas-aabha-cai");


    func hash(n : Nat) : Nat32 {
      return Blob.hash(Text.encodeUtf8(Nat.toText(n)));
    };
    
    stable var maxLoanToValue : Nat = 75;
    var propertyId : Nat= 0;
    let properties = HashMap.HashMap<Nat, Property>(0, Nat.equal, hash); 
    stable var custodians : [Principal] = [];

    public shared ({ caller }) func get_principal (): async Principal {
        return caller;
    };

    private func _authorised (caller : Principal): ?Text {
        let specificPrincipal = Principal.fromText("2e7fg-mfyxt-iivfx-l7pim-ysvwq-qetwz-h4rhz-t76tr-5zob4-oopr3-hae");
        if(caller != specificPrincipal ){
            return ?("You do not have permission to add a custodian");
        };
        return null;
    };

    public shared ({ caller }) func addCustodian (custodian: Principal): async Result<(),Text>{
        let result = _authorised(caller);
        if(Option.isNull(result)){
            return #err("You are not authorised to add custodians");
        };
        let newCustodian: [Principal] = [custodian];
        custodians := Array.append(custodians, newCustodian);
        return #ok();

    };

    public shared ({ caller }) func removeCustodian (custodian: Principal): async Result<(), Text>{
        let result = _authorised(caller);
        if(Option.isNull(result)){
            return #err("You are not authorised to add custodians");
        };
        var newArr: [Principal] = [];
        for (item in custodians.vals()) {
            if (item != custodian) {
                newArr := Array.append<Principal>(newArr, [item]);
            };
        };
        custodians := newArr;
        return #ok();
    };

    public shared ({ caller }) func updateLoanToValue (newLoanToValue : Nat): async Result<(), Text>{
         let result = _authorised(caller);
        if(Option.isNull(result)){
            return #err("You are not authorised to add custodians");
        };
        let maxLoan : Nat= 90;
        if(newLoanToValue > maxLoan){
            return #err("You are not allowed to issues loans with a greater loan to value than 90%");
        };
        maxLoanToValue := newLoanToValue;
        return #ok();
    };

    public shared ({ caller }) func addProperty (name: Text, addressLine1: Text, postcode: Text, purchasePrice: Nat): async Result<Property, Text> {
    if (Array.find<Principal>(custodians, func (x) = x == caller) == null){
        return #err("You are not authorised to add properties");
    };
      var newProperty: Property = {
          propertyId;
          name;
          addressLine1; 
          postcode;
          purchasePrice;
          currentValue = purchasePrice;
          loanAmount = 0;
          lNftN = [];
      };

      properties.put(propertyId, newProperty);
      propertyId += 1;
      return #ok(newProperty);
    };

    public shared ({ caller }) func updateProperty (propertyId: Nat, name: Text, addressLine1: Text, postcode: Text, purchasePrice: Nat, currentValue: Nat): async Result<Property, Text>{
        if (Array.find<Principal>(custodians, func (x) = x == caller) == null){
        return #err("You are not authorised to update properties");
        };
        switch (properties.get(propertyId)){
            case(null){
              return #err("There is no property with that id");
            };
            case(? property){
                let updateProperty : Property = {
                    propertyId;
                    name;
                    addressLine1;
                    postcode;
                    purchasePrice;
                    currentValue;
                    loanAmount = property.loanAmount;
                    lNftN = property.lNftN;
                };
                properties.put(propertyId, updateProperty);
                return #ok(updateProperty);
            };
  };
};

  public func getProperty(propertyId : Nat): async Result<Property,Text>{
    switch(properties.get(propertyId)){
        case(null){
            return #err("There is no property with that Id");
        };
        case(? property){
            return #ok(property);
        }
    }
  };

  public shared ({ caller }) func sellProperty (propertyId: Nat): async Result<Property, Text>{
     if (Array.find<Principal>(custodians, func (x) = x == caller) == null){
        return #err("You are not authorised to sell properties");
    };
    switch(properties.get(propertyId)){
        case(null){
            return #err("There is no property with that Id")
        };
        case(? property){
            properties.delete(propertyId);
            return #ok(property);
        }
    }
  };

    func _calculateMaxLoan (currentValue : Nat): Nat{
        let loan : Nat = Nat.div(Nat.mul(currentValue, maxLoanToValue),100);
        return loan; 
    };

    public shared ({ caller }) func makeLoan (propertyId : Nat): async Result<[Nat],ComprehensiveError>{
        if (Array.find<Principal>(custodians, func (x) = x == caller) == null){
            return #err(#Icrc1(#Unauthorized));
        };

        var property : Property = switch(properties.get(propertyId)){
            case(null){ return #err(#Icrc1(#PropertyNotFound)) };
            case(? property){ property }
        };

        let maxLoan = _calculateMaxLoan(property.currentValue);

        let additionalLoan = if(Nat.greater(maxLoan, property.loanAmount)){Nat.sub(maxLoan, property.loanAmount)} else{ 0 };
        let decimals = await hgb.icrc1_decimals();
        let aHGB = Nat.pow(10, Nat8.toNat(decimals));
        let hgbToMint = Nat.mul(aHGB, additionalLoan);
        let hgbMint = await hgb.icrc1_mint({owner = Principal.fromText("xgewh-5qaaa-aaaas-aaa3q-cai"); subaccount= null}, hgbToMint);
        switch(hgbMint){
            case(#ok){};
            case(#err error){return #err(#Swap(error))};
        };
        let lNFTsToMint = Nat.div(additionalLoan, 1000);
        let mintLNFT = await lnft.icrc7_mint_batch(lNFTsToMint);
        var tokenIds : [Nat] = [];
        switch(mintLNFT){
            case(#ok tokens){ tokenIds := Array.append(property.lNftN, tokens)};
            case(#err error){ return #err(#Swap(error))};
        };
        let updatedProperty : Property = {
            propertyId = propertyId;
            name = property.name;
            addressLine1 =  property.addressLine1;
            postcode = property.postcode;
            purchasePrice = property.purchasePrice;
            currentValue = property.currentValue;
            loanAmount = maxLoan;
            lNftN = tokenIds;
        };
        properties.put(propertyId, updatedProperty);
        return #ok(tokenIds)
    };


//logic for selling HGB on exchange once it's on ICPSWAP for now I'm using ICP and EXE

    
    let exe : actor {
        icrc1_balance_of: query Account -> async Nat;
        icrc1_transfer : shared TransferArgs -> async TransferResult;
    } = actor("rh2pm-ryaaa-aaaan-qeniq-cai");

    let icpExeSwap : actor {
        quote : shared query SwapArgs -> async Result1;
        deposit : shared DepositArgs -> async Result1;
        swap : shared SwapArgs -> async Result1;
        withdraw : shared WithdrawArgs -> async Result1;
    } = actor("dlfvj-eqaaa-aaaag-qcs3a-cai");

    public func principalToBlob(p: Principal): async Blob {
        var arr: [Nat8] = Blob.toArray(Principal.toBlob(p));
        var defaultArr: [var Nat8] = Array.init<Nat8>(32, 0);
        defaultArr[0] := Nat8.fromNat(arr.size());
        var ind: Nat = 0;
        while (ind < arr.size() and ind < 32) {
            defaultArr[ind + 1] := arr[ind];
            ind := ind + 1;
        };
        return Blob.fromArray(Array.freeze(defaultArr));
    };

    public shared ({ caller }) func getUserPrincipal (): async Principal {
        return caller
   };

    public func getExeBalance(owner: Principal): async Nat {
        let account : Account = {
            owner;
            subaccount = null;
        };
        return await exe.icrc1_balance_of(account);
    };

    public func getDepositBalance(): async Nat {
        let subaccount1 = await principalToBlob(Principal.fromText("dlfvj-eqaaa-aaaag-qcs3a-cai"));
        let swapAccount : Account = {
            owner = Principal.fromText("dlfvj-eqaaa-aaaag-qcs3a-cai");
            subaccount = ?subaccount1;
        };
        return await exe.icrc1_balance_of(swapAccount);
    };

    public func sendEXEforExchange(amount: Nat): async TransferResult {
        let subaccount1 = await principalToBlob(Principal.fromText("xgewh-5qaaa-aaaas-aaa3q-cai"));
        let swapAccount : Account = {
            owner = Principal.fromText("dlfvj-eqaaa-aaaag-qcs3a-cai");
            subaccount = ?subaccount1;
        };
        let transfer : TransferArgs = {
            amount;
            created_at_time = null;
            fee = ?100000;
            from_subaccount = null;
            memo = null;
            to = swapAccount;
        };
        return await exe.icrc1_transfer(transfer);
    };

    public func transferHGB (to : Account, amount : Nat): async  Result<(),Error1> {
        let ourAccount = {
            owner = Principal.fromText("xgewh-5qaaa-aaaas-aaa3q-cai");
            subaccount = null;
        };
        return await hgb.icrc1_transfer(ourAccount, to, amount);
    };

    public func balanceHGB (): async Nat {
        let ourAccount = {
            owner = Principal.fromText("xgewh-5qaaa-aaaas-aaa3q-cai");
            subaccount = null;
        };
        return await hgb.icrc1_balance_of(ourAccount);
    };

    public func quoteIcpExeSwap(amountIn: Text): async Result1 {
        let swapquote : SwapArgs = {
            amountIn;
            zeroForOne = true;
            amountOutMinimum = "0";
        };
        return await icpExeSwap.quote(swapquote);
    };

    public func sendDepositEXE(amount: Nat): async Result1 {
        let deposit : DepositArgs = { 
            fee = 100000; 
            token = "rh2pm-ryaaa-aaaan-qeniq-cai"; 
            amount;
        };
        Debug.print("Attempting to deposit EXE: " # Nat.toText(amount) # " to icpExeSwap canister");
        return await icpExeSwap.deposit(deposit);
    };

    public func swapEXE(amount: Text): async Result1 {
        let swapArg : SwapArgs = {
            amountIn = amount; 
            zeroForOne = true;
            amountOutMinimum = "0";
        };
        return await icpExeSwap.swap(swapArg);
    };

    public func withdrawICPafterSwap(amount: Nat): async Result1 {
        let withdraw : WithdrawArgs = {
            fee = 10000; 
            token = "ryjl3-tyaaa-aaaaa-aaaba-cai"; 
            amount;
        };
        return await icpExeSwap.withdraw(withdraw);
    };

    // Add logging for each step
    public func swapExeForIcp(initialExeAmount: Nat): async Result1 {
        var result : Nat = 0;
        let balance = await getExeBalance(Principal.fromText("4ew6i-ryaaa-aaaas-aabga-cai"));
        if(initialExeAmount > balance){
            return  #err(#InsufficientFunds);
        };
        //transfer
        ignore await sendEXEforExchange(initialExeAmount);
        //deposit
        let depositResult = await sendDepositEXE(initialExeAmount);
        switch(depositResult){
            case(#ok(amount)){result := amount};
            case(#err(error)){return #err(error)}
        };
        //swap
        let swapResult = await swapEXE(Nat.toText(result));
        switch(swapResult){
            case(#ok(amount)){result := amount};
            case(#err(error)){return #err(error)};
        };
        //withdraw
        let withdrawResult = await withdrawICPafterSwap(result);
        switch(withdrawResult){
            case(#ok(amount)){return #ok(amount)};
            case(#err(error)){return #err(error)};
        };
    };
}

