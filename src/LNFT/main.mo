import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Types "./../property_database/types";


actor SimpleNFTCollection {
    type TokenId = Types.TokenId;
    type Attribute = Types.Attribute;
    type Result<A, B> = Result.Result<A, B>;
    type Hash = Hash.Hash;
    type Account = Types.Account;
    type Metadata = Types.Metadata;
    type Token = Types.Token;
    public type TransactionTypes = Types.TransactionTypes;
    type Transaction = Types.Transaction;
    type Approval = Types.Approval;
    public type Error = Types.Error;
    public type TransferArgs = Types.TransferArgs;
    public type TransferError = Types.TransferError;
    public type ApprovalArgs = Types.ApprovalArgs;
    public type ApprovalError = Types.ApprovalError;

    func accountEqual(x: Account, y: Account): Bool {
      if(x.owner == y.owner and x.subaccount == y.subaccount){
        return true;
      };
      return false;
    };

    func accountHash (x:Account): Hash {
      return Principal.hash(x.owner);
    };

    func hash(n : Nat) : Nat32 {
      return Blob.hash(Text.encodeUtf8(Nat.toText(n)));
    };

    let admin: Principal = Principal.fromText("xgewh-5qaaa-aaaas-aaa3q-cai"); 
    stable var nextTokenId: TokenId = 0;
    private var tokens: HashMap.HashMap<TokenId, Token> = HashMap.HashMap<TokenId, Token>(0, Nat.equal, hash);
    private var ownerTokens: HashMap.HashMap<Account, [TokenId]> = HashMap.HashMap<Account, [TokenId]>(0, accountEqual, accountHash);
    private var transactions: HashMap.HashMap<TokenId, [Transaction]> = HashMap.HashMap<TokenId, [Transaction]>(0, Nat.equal, hash);
    private stable var approvals: [Approval] = [];

    // Function to log transactions
    func logTransaction(action: TransactionTypes, tokenId: TokenId, from: ?Account, to: ?Account): () {
        let transaction : Transaction = {
            id = transactions.size();
            action = action;
            tokenId = tokenId;
            from = from;
            to = to;
            timestamp = Time.now();
        };
        let currentTransactions = Option.get(transactions.get(tokenId), []);
        transactions.put(tokenId, Array.append(currentTransactions, [transaction]));
    };

    // Function to validate metadata
    func validateMetadata(metadata: Metadata): Result<(), Error> {
        if (metadata.name == "" or metadata.image == "" or metadata.description == "") {
            return #err(#InvalidInput);
        };
        if (metadata.name.size() > 100) {
            return #err(#InvalidInput);
        };
        if (metadata.description.size() > 1000) {
            return #err(#InvalidInput);
        };
        if (not Text.startsWith(metadata.image, #text "http://") and not Text.startsWith(metadata.image, #text "https://")) {
            return #err(#InvalidInput);
        };
        if (metadata.creationDate > Time.now()) {
            return #err(#InvalidInput);
        };
        return #ok(());
    };

    // ICRC-7: Mint function
    //Okay this function should be altered somewhat - shouldn't need parameters, set loanNFT metadata and owner as exchange account
    public shared ({ caller }) func icrc7_mint(owner: Account, metadata: Metadata): async Result<TokenId, Error> {
        if (Principal.notEqual(admin, caller)) {
            return #err(#Unauthorized);
        };

        switch (validateMetadata(metadata)) {
            case (#err(e)) { return #err(e); };
            case (#ok(())) {};
        };

        let tokenId = nextTokenId;
        nextTokenId += 1;

        if (Option.isSome(tokens.get(tokenId))) {
            return #err(#TokenAlreadyExists);
        };

        let token: Token = {
            id = tokenId;
            owner = owner;
            metadata = metadata;
        };

        tokens.put(tokenId, token);

        let ownerTokenList = switch (ownerTokens.get(owner)) {
            case (null) { [tokenId] };
            case (?ids) { Array.append(ids, [tokenId]) };
        };

        ownerTokens.put(owner, ownerTokenList);

        logTransaction(#Mint, tokenId, null, ?owner);

        return #ok(tokenId);
    };
//Mint all NFTs for a specific property
    public shared ({ caller }) func icrc7_mint_batch(number : Nat): async Result<[TokenId], Error> {
        if (Principal.notEqual(admin, caller)) {
            return #err(#Unauthorized);
        };
        
        let owner : Account = {
            owner = Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
            subaccount = null;
        };
        
        let lnft : Metadata = {
            name = "LNFT";
            description = "Loan NFT - worth 1,000 pounds";
            image = ""; // URL to the image
            creator = admin;
            creationDate = Time.now();
            attributes = [];
        };
        var tokenIds : [Nat] = [];

        for(i in Iter.range(nextTokenId, Nat.add(nextTokenId, number))){

        let tokenId = nextTokenId;
        nextTokenId += 1;


        if (Option.isSome(tokens.get(tokenId))) {
            return #err(#TokenAlreadyExists);
        };

        let token: Token = {
            id = tokenId;
            owner;
            metadata = lnft;
        };

        tokens.put(tokenId, token);
        tokenIds := Array.append(tokenIds, [tokenId]);
        
        logTransaction(#Mint, tokenId, null, ?owner);
        };

        let ownerTokenList = switch (ownerTokens.get(owner)) {
            case (null) { tokenIds };
            case (?ids) { Array.append(ids, tokenIds) };
        };

        ownerTokens.put(owner, ownerTokenList);

        return #ok(tokenIds);
    };

    // ICRC-7: Transfer function
    public shared ({caller}) func icrc7_transfer(args: TransferArgs): async Result<Nat, TransferError> {
    for (tokenId in args.token_ids.vals()) {
        switch (tokens.get(tokenId)) {
            case (null) { return #err(#TemporarilyUnavailable);};
            case (?token) {
                if (caller != token.owner.owner and not (await isApproved(token.owner, tokenId))) {
                    return #err(#Unauthorized({ token_ids = args.token_ids }));
                };
                try {
                    tokens.put(tokenId, { token with owner = args.to });

                    let fromOwnerTokenList = switch (ownerTokens.get(token.owner)) {
                        case (null) { [] };
                        case (?ids) { Array.filter<Nat>(ids, func (id: Nat): Bool { id != tokenId }) };
                    };
                    ownerTokens.put(token.owner, fromOwnerTokenList);

                    let toOwnerTokenList = switch (ownerTokens.get(args.to)) {
                        case (null) { [tokenId] };
                        case (?ids) { Array.append(ids, [tokenId]) };
                    };
                    ownerTokens.put(args.to, toOwnerTokenList);

                    logTransaction(#Transfer, tokenId, ?token.owner, ?args.to);
                } catch (_) {
                return #err(#GenericError({ error_code = 1; message = "Internal error occurred during token transfer" }))
                };
            };
        }
    };
    return #ok(args.token_ids.size());
};


    // ICRC-7: Burn function
    public shared ({caller}) func icrc7_burn(tokenId: TokenId): async Result<Bool, Error> {
        switch (tokens.get(tokenId)) {
            case (null) { return #err(#TokenNotFound); };
            case (?token) {
                if (caller != token.owner.owner) {
                    return #err(#Unauthorized);
                };
                try {
                    tokens.delete(tokenId);
                    let updatedOwnerTokenList = switch (ownerTokens.get(token.owner)) {
                        case (null) { [] };
                        case (?ids) { Array.filter<Nat>(ids, func (id: Nat): Bool { id != tokenId }) };
                    };
                    ownerTokens.put(token.owner, updatedOwnerTokenList);
                    logTransaction(#Burn, tokenId, ?token.owner, null);
                    return #ok(true);
                } catch (_) {
                    return #err(#InternalError);
                }
            };
        }
    };

    // ICRC-7: Approve function
    public shared ({caller}) func icrc7_approve(args: ApprovalArgs): async Result<Nat, ApprovalError> {
        for(i in args.token_ids.vals()){
            switch (tokens.get(i)) {
                case (null) { return #err(#Unauthorized); };
                case (?token) {
                    let exchangeCanister : Principal = Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");
                    if (Principal.notEqual(caller, token.owner.owner) and Principal.notEqual(caller, exchangeCanister)) {
                        return #err(#Unauthorized);
                    };
                };
            };
            let approval : Approval = { 
                owner = { owner = args.owner.owner; subaccount = args.owner.subaccount }; 
                approved = { owner = args.spender; subaccount = null }; 
                tokenId = i 
                };
            approvals := Array.append(approvals, [approval]);
        };
        return #ok(args.token_ids.size());
    };


    public shared ({caller}) func isApproved(owner: Account, tokenId: TokenId): async Bool {
        let exchangeCanister = Principal.fromText("wcjzv-eqaaa-aaaas-aaa5q-cai");

        for (approval in approvals.vals()) {
            if ((accountEqual(approval.owner, owner) and approval.tokenId == tokenId and (approval.approved.owner == caller or approval.approved.owner == exchangeCanister))) {
                return true;
            }
        };

        return false;
    };

    // ICRC-7: Metadata function
    public query func icrc7_metadata(token_id: TokenId): async Result<Metadata, Error> {
        switch (tokens.get(token_id)) {
            case (null) { return #err(#TokenNotFound); };
            case (?token) { return #ok(token.metadata); };
        }
    };

        // ICRC-7: Owner of function
    public query func icrc7_owner_of(token_id: TokenId): async Result<Account, Error> {
        switch (tokens.get(token_id)) {
            case (null) { return #err(#TokenNotFound); };
            case (?token) { return #ok(token.owner); };
        }
    };

    // ICRC-7: Balance of function
    public query func icrc7_balance_of(account: Account): async Nat {
        switch (ownerTokens.get(account)) {
            case (null) { return 0; };
            case (?ids) { return ids.size(); };
        }
    };

    // ICRC-7: Tokens of function
    public query func icrc7_tokens_of(account: Account): async [TokenId] {
        switch (ownerTokens.get(account)) {
            case (null) { return []; };
            case (?ids) { return ids; };
        }
    };

    // ICRC-7: Supported standards function
    public query func icrc7_supported_standards(): async [{ name: Text; url: Text }] {
        return [
            { name = "ICRC-7"; url = "https://github.com/dfinity/ICRC" },
            // Add other supported standards if any
        ];
    }
}
