use starknet::ContractAddress;

#[starknet::interface]
trait IERC721Starknet<TContractState> {
    // fn increase_balance(ref self: TContractState, amount: felt252);
    // fn get_balance(self: @TContractState) -> felt252;
    fn balance_of(self: @TContractState, owner_address: ContractAddress) -> u256;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(
        ref self: @TContractState,
        from_address: ContractAddress,
        to_address: ContractAddress,
        token_id: u256,
        data: ByteArray
    );
    fn safe_transfer_from(
        ref self: @TContractState,
        from_address: ContractAddress,
        to_address: ContractAddress,
        token_id: u256
    );
    fn transfer_from(
        ref self: @TContractState,
        from_address: ContractAddress,
        to_address: ContractAddress,
        token_id: u256
    );
    fn approve(ref self: @TContractState, approved_address: ContractAddress, token_id: u256);
    fn set_approval_for_all(
        ref self: @TContractState, operator_address: ContractAddress, approved: bool
    );
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(
        self: @TContractState, owner_address: ContractAddress, operator_address: ContractAddress
    ) -> bool;
}

#[starknet::interface]
trait IERC165<TContractState> {
    fn support_interface(self: @TContractState, interface_id: ByteArray) -> bool;
}
#[starknet::interface]
trait IERC721TokenReceiver<TContractState> {
    fn on_erc721_received(
        ref self: @TContractState,
        operator_address: ContractAddress,
        from_address: ContractAddress,
        token_id: u256,
        data: ByteArray
    ) -> ByteArray;
}
#[starknet::interface]
trait IERC721Metadata<TContractState> {
    fn name(self: @ContractState) -> felt252;
    fn symbol(self: @ContractState) -> felt252;
    fn token_URI(self: @ContractState, token_id: u256) -> felt252;
}

#[starknet::interface]
trait IERC721Enumerable<TContractState> {
    fn total_supply(self: @ContractState) -> u256;
    fn token_by_index(self: @ContractState, index: u256) -> u256;
    fn token_owner_by_index(
        self: @ContractState, owner_address: ContractAddress, index: u256
    ) -> u256;
}

#[starknet::contract]
mod ERC721 {
    use starknet::{ContractAddress};
    use starknet::contract_address::ContractAddressZeroable;
    #[storage]
    struct Storage {
        name:felt252,
        symbol:felt252,
        // balance: felt252,
        owners:LegacyMap::<u256, ContractAddress>,
        balances:LegacyMap::<ContractAddress, u256>,
        tokenApprovals:LegacyMap::<u256, ContractAddress>,
        operatorApprovals:LegacyMap::<(ContractAddress, ContractAddress), bool>
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from_address: ContractAddress,
        to_address: ContractAddress,
        token_id: u256
    }
    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner_address: ContractAddress,
        approved_address: ContractAddress,
        token_id: u256
    }
    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        owner_address: ContractAddress,
        operator_address: ContractAddress,
        approved: bool
    }

    mod Errors{
        const NON_EXISTENT_ID: felt252='ID_DOES_NOT_EXIST';
        const INVALID_APPROVAL:felt252 = 'INSUFFICIENT_APPROVAL';
    }
    #[constructor]
    fn constructor(ref self:ContractState, _name:felt252, _symbol:felt252 ){
        self.name.wirte(_name);
        self.symbol.write(_symbol);
    }

    #[external(v0)]
    impl ERC721StarknetImpl of super::IERC721Starknet<ContractState> {
        // fn increase_balance(ref self: ContractState, amount: felt252) {
        //     assert(amount != 0, 'Amount cannot be 0');
        //     self.balance.write(self.balance.read() + amount);
        // }

        // fn get_balance(self: @ContractState) -> felt252 {
        //     self.balance.read()
        // }

        fn balance_of(self: @ContractState, owner_address: ContractAddress) -> u256 {
            assert(!owner_address.is_zero(), 'zero address');
            let token_balance = self.balances.read(owner_address);
            token_balance
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            self.owners.read(token_id)
        }
        fn safe_transfer_from(
            ref slef: @ContractState,
            from_address: ContractAddress,
            to_address: ContractAddress,
            token_id: u256,
            data: ByteArray
        ) {

        }
        fn safe_transfer_from(
            ref self: @ContractState,
            from_address: ContractAddress,
            to_address: ContractAddress,
            token_id: u256
        ) {}
        fn transfer_from(
            ref self: @ContractState,
            from_address: ContractAddress,
            to_address: ContractAddress,
            token_id: u256
        ) {
            assert(!to_address.is_zero(), 'INVALID_ADDRESS');

             address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }

        }
        fn approve(ref slef: @ContractState, approved_address: ContractAddress, token_id: u256) {}
        fn set_approval_for_all(
            ref self: @ContractState, operator_address: ContractAddress, approved: bool
        ) {}
        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {}
        fn is_approved_for_all(
            self: @ContractState, owner_address: ContractAddress, operator_address: ContractAddress
        ) -> bool {}
    }
    #[external(v0)]
    impl ERC165Impl of super::IERC165<ContractState> {
        fn support_interface(self: ContractState, interface_id: ByteArray) -> bool {

        }
    }
    #[external(v0)]
    impl ERC721TokenReceiverImpl of super::IERC721TokenReceiver<ContractState> {
        fn on_erc721_received(
            self: ContractState,
            operator_address: ContractAddress,
            from_address: ContractAddress,
            token_id: u256,
            data: ByteArray
        ) -> ByteArray {}
    }
    #[external(v0)]
    impl ERC721MetadataImpl of super::IERC721Metadata<ContractState> {
        fn name(self: ContractState) -> felt252 {}
        fn symbol(self: ContractState) -> felt252 {}
        fn token_URI(self: ContractState, token_id: u256) -> felt252 {}
    }

    #[external(v0)]
    impl ERC721EnumerableImpl of super::IERC721Enumerable<ContractState> {
    fn total_supply(self: ContractState) -> u256{

    }
    fn token_by_index(self: ContractState, index: u256) -> u256{

    }
    fn token_owner_by_index(
        self: ContractState, owner_address: ContractAddress, index: u256
    ) -> u256{

    }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
       fn _update(ref self:ContractState, to: ContractAddress, token_id:u256, auth: ContractAddress){

        let from: ContractAddress = self.owners.read(token_id);


        if !auth.is_zero{
            self._check_authorised()
        }
       }

       fn _check_authorised(ref self:ContractState, _owner:ContractAddress, _spender:ContractAddress, token_id:u256)->(){
        if self._isAuthorized(_owner, _spender, token_id) == false{
            assert(!_owner.is_zero(), Errors::NON_EXISTENT_ID);
            Errors::INVALID_APPROVAL;
            return;
        }
       }

       fn _isAuthorized(ref self:ContractState, _owner:ContractAddress, _spender:ContractAddress, token_id:u256)->bool{
        assert(!spender.is_zero(), 'ZERO_ADDRESS');
        if _owner==_spender || self._isApproved_for_all(_owner, _spender) || self._get_Approved(token_id) ==spender{
            true
        }
        else{
            false
        }

       }

       fn _isApproved_for_all(self: ContractState, _owner:ContractAddress, _operator:ContractAddress) ->bool{
        self.operatorApprovals.read(_owner, _operator)

       }

       fn _get_Approved(self:ContractState, token_id:u256) ->ContractAddress{
        self.tokenApprovals.read(token_id)
       }
    }
}
