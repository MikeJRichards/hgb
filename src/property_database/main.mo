import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Int "mo:base/Nat";
import Blob "mo:base/Blob";
import ICRC2 "mo:icrc2-types";
import Int32 "mo:base/Int32";
import Time "mo:base/Time";
import ICRC7 "mo:icrc7-mo";
import Nat64 "mo:base/Nat64";

actor {
    public type Subaccount = Blob;
    public type Account = { owner : Principal; subaccount : ?Subaccount };
    public type Tokens = Nat;
    public type Memo = Blob;
    public type Result<A,B> = Result.Result<A,B>;
    public type Property = {
      propertyId: Nat;
      name: Text;
      addressLine1: Text;
      postcode: Text;
      purchasePrice: Nat;
      currentValue: Nat;
      loanAmount: Nat;
      lNftN : Int;
    };
    
    stable var maxLoanToValue : Nat = 75;
    var propertyId : Nat= 0;
    stable var propertyEntries : [Property] = [];
    let properties = HashMap.HashMap<Nat, Property>(0, Nat.equal, Hash.hash); 
    stable var custodians : [Principal] = [];

    let hgb_token : actor {
		icrc2_transfer_from : shared (caller: Principal, spender_subaccount: ?Blob, from :Account, to: Account, amount: Nat, fee: ?Nat, memo: ?Blob, created_at_time: ?Nat64) -> async (Nat, ICRC2.TransferFromError); 
	} = actor ("b77ix-eeaaa-aaaaa-qaada-cai");

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
    //if (Array.find<Principal>(custodians, func (x) = x == caller) == null){
    //    return #err("You are not authorised to add properties");
    //};
      var newProperty: Property = {
          propertyId;
          name;
          addressLine1; 
          postcode;
          purchasePrice;
          currentValue = purchasePrice;
          loanAmount = 0;
          lNftN = 0;
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
        return #err("You are not authorised to add properties");
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
        let loan : Nat = Nat.mul(Nat.div(currentValue, maxLoanToValue),100);
        return loan; 
    };

    public func mintNFTToExchange (): async (){
        let exchangeCanister = {
                owner = Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
                subaccount = null
            };
        //ignore await icrc7nft.assign(2, exchangeCanister);
        var token_id = await icrc7nft.icrc7_total_supply();
        token_id += 1;
        let nftRequest : ICRC7.SetNFTItemRequest = {
            token_id;
            metadata = #Nat(1000);
            owner = ?exchangeCanister;
            override = true;
            memo = null;
            created_at_time = null;
        };

        ignore await icrc7nft.icrcX_mint([nftRequest]);

       //let transfer : ICRC7.TransferArg = {
       //     from_subaccount = null;
       //     to = exchangeCanister;
       //     token_id = 1; 
       //     memo = null;
       //     created_at_time = ?Nat64.fromIntWrap(Time.now());
       // };
//
       // ignore await icrc7nft.icrc7_transfer([transfer]);
        return ();
    };

  public shared ({ caller }) func makeMaxLoan (propertyId: Nat): async Result<(), Text>{
    // if (Array.find<Principal>(custodians, func (x) = x == caller) == null){
    //    return #err("You are not authorised to add properties");
    //};
    switch(properties.get(propertyId)){
        case(null){
            return #err("This is not a valid property Id")
        };
        case(? property){
            var newLoan : Nat = _calculateMaxLoan(property.currentValue);//Float.floor(Float.fromInt((property.currentValue) * maxLoanToValue/1000));
            let additionalLoan : Nat = newLoan - property.loanAmount;//newLoan -  Int.abs(property.loanAmount);

            let updatedProperty : Property = {
                propertyId;
                name = property.name;
                addressLine1 = property.addressLine1;
                postcode = property.postcode;
                purchasePrice = property.purchasePrice;
                currentValue = property.currentValue;
                loanAmount = newLoan * 1000;
                lNftN = additionalLoan;

            };
            let minter = {
                owner = Principal.fromText("2e7fg-mfyxt-iivfx-l7pim-ysvwq-qetwz-h4rhz-t76tr-5zob4-oopr3-hae"); 
                subaccount = null
            };
            let saleCanister = {
                owner = Principal.fromText("wfi7b-jiaaa-aaaas-aaa5a-cai"); 
                subaccount = null
            };
            let exchangeCanister = {
                owner = Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
                subaccount = null
            };
            //ignore await hgb_token.icrc2_transfer_from(caller, null, minter, saleCanister, additionalLoan, null, null, null);
            //ignore await icrc7nft.assign(2, exchangeCanister);
           // icrc7nft.icrc7_transfer
            //ignore await icrc7nft.icrcX_mint(additionalLoan, exchangeCanister, );
            properties.put(propertyId, updatedProperty);
            return #ok();
        }

    }
  };

  system func preupgrade() {
      propertyEntries := Iter.toArray(properties.vals());
    };
    
    system func postupgrade() {
      propertyId := 0;
      for(item in propertyEntries.vals()){
        properties.put(propertyId, item);
        propertyId +=1;
      };  
      propertyEntries := [];
    };
};
