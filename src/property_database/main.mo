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

actor {
    public type Result<A,B> = Result.Result<A,B>;
    public type Property = {
      propertyId: Nat;
      name: Text;
      addressLine1: Text;
      postcode: Text;
      purchasePrice: Int;
      currentValue: Int;
      loanAmount: Int;
      lNftN : Int;
    };
    
    stable var maxLoanToValue : Float = 0.75;
    var propertyId : Nat= 0;
    stable var propertyEntries : [Property] = [];
    let properties = HashMap.HashMap<Nat, Property>(0, Nat.equal, Hash.hash); 
    stable var custodians : [Principal] = [];

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

    public shared ({ caller }) func updateLoanToValue (newLoanToValue : Float): async Result<(), Text>{
         let result = _authorised(caller);
        if(Option.isNull(result)){
            return #err("You are not authorised to add custodians");
        };
        let maxLoan : Float= 0.9;
        if(newLoanToValue > maxLoan){
            return #err("You are not allowed to issues loans with a greater loan to value than 90%");
        };
        maxLoanToValue := newLoanToValue;
        return #ok();
    };

    public shared ({ caller }) func addProperty (name: Text, addressLine1: Text, postcode: Text, purchasePrice: Int): async Result<Property, Text> {
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
          lNftN = 0;
      };

      properties.put(propertyId, newProperty);
      propertyId += 1;
      return #ok(newProperty);
    };

    public shared ({ caller }) func updateProperty (propertyId: Nat, name: Text, addressLine1: Text, postcode: Text, purchasePrice: Int, currentValue: Int): async Result<Property, Text>{
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

  public shared ({ caller }) func makeMaxLoan (propertyId: Nat): async Result<(), Text>{
     if (Array.find<Principal>(custodians, func (x) = x == caller) == null){
        return #err("You are not authorised to add properties");
    };
    switch(properties.get(propertyId)){
        case(null){
            return #err("This is not a valid property Id")
        };
        case(? property){
            var newLoan : Int = Float.toInt(Float.floor((Float.fromInt(property.currentValue) * maxLoanToValue)/1000));
            let additionalLoan = newLoan -  property.loanAmount;

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
