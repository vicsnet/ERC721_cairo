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
    use starknet::{ContractAddress, get_caller_address};
    use starknet::contract_address::ContractAddressZeroable;
    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        uri:felt252,
        // balance: felt252,
        owners: LegacyMap::<u256, ContractAddress>,
        balances: LegacyMap::<ContractAddress, u256>,
        tokenApprovals: LegacyMap::<u256, ContractAddress>,
        operatorApprovals: LegacyMap::<(ContractAddress, ContractAddress), bool>
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

    mod Errors {
        const NON_EXISTENT_ID: felt252 = 'ID_DOES_NOT_EXIST';
        const INVALID_APPROVAL: felt252 = 'INSUFFICIENT_APPROVAL';
    }
    #[constructor]
    fn constructor(ref self: ContractState, _name: felt252, _symbol: felt252) {
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
        // fn safe_transfer_from(
        //     ref slef: @ContractState,
        //     from_address: ContractAddress,
        //     to_address: ContractAddress,
        //     token_id: u256,
        //     data: ByteArray
        // ) {
        //     self.transfer_from(from_address, to_address, token_id);

        // }
        // fn safe_transfer_from(
        //     ref self: @ContractState,
        //     from_address: ContractAddress,
        //     to_address: ContractAddress,
        //     token_id: u256
        // ) {

            
        // }
        fn transfer_from(
            ref self: @ContractState,
            from_address: ContractAddress,
            to_address: ContractAddress,
            token_id: u256
        ) {
            assert(!to_address.is_zero(), 'INVALID_ADDRESS');

            address
            previousOwner = _update(to, tokenId, _msgSender());
            assert(previousOwner != from, 'INCORRECT_OWNER');

        }
        fn approve(ref slef: @ContractState, approved_address: ContractAddress, token_id: u256) {
            let caller = get_caller_address();
            self._approve(approved_address,token_id, caller);
        }

        fn set_approval_for_all(
            ref self: @ContractState, operator_address: ContractAddress, approved: bool
        ) { 
            assert(!operator_address.is_zero(), 'ZERO_ADDRESS');
            let caller:ContractAddress = get_caller_address();
            self.operatorApprovals.write((caller, operator_address), approved);
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            self._requireOwned(token_id);
            self._get_Approved(token_id)

        }

        fn is_approved_for_all(
            self: @ContractState, owner_address: ContractAddress, operator_address: ContractAddress
        ) -> bool {
            self._is_approved_for_all(owner_address, operator_address)
        }
    }
    #[external(v0)]
    impl ERC165Impl of super::IERC165<ContractState> {
        fn support_interface(self: ContractState, interface_id: ByteArray) -> bool {}
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
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }
        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }
        fn token_URI(self: @ContractState) -> felt252 {
            self.uri.read();
        }
        fn set_URI(ref self: ContractState, token_uri:felt252){
            self.uri.write(token_uri);
        }
        // fn token_URI(self: ContractState, token_id: u256) -> felt252 {
        //     self.uri.read();
        // }
    }

    #[external(v0)]
    impl ERC721EnumerableImpl of super::IERC721Enumerable<ContractState> {
        fn total_supply(self: ContractState) -> u256 {}
        fn token_by_index(self: ContractState, index: u256) -> u256 {}
        fn token_owner_by_index(
            self: ContractState, owner_address: ContractAddress, index: u256
        ) -> u256 {}
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn _update(
            ref self: ContractState, to: ContractAddress, token_id: u256, auth: ContractAddress
        ) ->ContractAddress{
            let from: ContractAddress = self.owners.read(token_id);
               let Address0: ContractAddress = 0.try_into().unwrap();

            if !auth.is_zero() {
                self._check_authorised(from, auth, token_id);
            }
            if !from.is_zero() {
                self._approve(Address0, token_id, Address0, false);
                self.balances.write(from, self.balances.read(from)-1);
            }
            if !to.is_zero(){
                self.balances.write(to, self.balances.read(to) + 1);
            }
            self.owners.write(token_id, to);
            self.emit(Transfer{
                from_address:from, to_address: to, token_id:token_id
            });
            from
        }

        fn _check_authorised(
            ref self: ContractState,
            _owner: ContractAddress,
            _spender: ContractAddress,
            token_id: u256
        ) -> () {
            if self._isAuthorized(_owner, _spender, token_id) == false {
                assert(!_owner.is_zero(), Errors::NON_EXISTENT_ID);
                Errors::INVALID_APPROVAL;
                return;
            }
        }

        fn _isAuthorized(
            ref self: ContractState,
            _owner: ContractAddress,
            _spender: ContractAddress,
            token_id: u256
        ) -> bool {
            assert(!spender.is_zero(), 'ZERO_ADDRESS');
            if _owner == _spender
                || self._isApproved_for_all(_owner, _spender)
                || self._get_Approved(token_id) == spender {
                true
            } else {
                false
            }
        }

        fn _is_approved_for_all(
            self: ContractState, _owner: ContractAddress, _operator: ContractAddress
        ) -> bool {
            self.operatorApprovals.read(_owner, _operator)
        }

        fn _get_Approved(self: ContractState, token_id: u256) -> ContractAddress {
            self.tokenApprovals.read(token_id)
        }

        fn _approve(
            ref self: ContractState,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress,
            emitEvent: bool
        ) {
            if emitEvent == true || !auth.is_zero() {
                let owner: ContractAddress = self._requireOwned(token_id);

                assert(
                    owner == auth
                        && !auth.is_zero()
                        && self._isApproved_for_all(owner, auth) == false,
                    'INVALID_APPROVAL'
                );
                if emitEvent == true{
                    self.emit(
                        Approval{
                            owner_address:owner, approved_address:to,
                            token_id:token_id
                        }
                    );
                }
                self.tokenApprovals.write(token_id, to);
            }
        }

        fn _requireOwned(ref self: ContractState, token_id: u256) -> ContractAddress {
            let owner: ContractAddress = self.owners.read(token_id);
            assert(!owner.is_zero(), 'NON_EXISTENT_TOKEN');
            owner
        }
        // fn _check_onERC721_received(ref self:ContractState, from_address:ContractAddress, to_address:ContractAddress, token_id:u256, data:ByteArray){
            
        // }
    }
}
