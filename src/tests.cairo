use storage_read::interface::IStorageReadDispatcherTrait;
use core::option::OptionTrait;
use core::traits::TryInto;
use storage_read::{
    main::{
        storage_read_component,
        storage_read_component::{HasComponent, StorageReadImpl, component_state_for_testing}
    },
    interface::{IStorageRead, IStorageReadDispatcher}
};
use starknet::{ContractAddress, SyscallResultTrait, StorageAddress};

#[starknet::interface]
trait ITestContract<TContractState> {
    fn write_simple(ref self: TContractState, value: felt252);

    fn write_mapping(ref self: TContractState, key: felt252, value: felt252);
}


#[starknet::contract]
mod DummyContract {
    use starknet::ContractAddress;
    use storage_read::main::storage_read_component;

    component!(path: super::storage_read_component, storage: storage_read, event: StorageReadEvent);

    impl StorageReadComponent = storage_read_component::StorageReadImpl<ContractState>;

    #[abi(embed_v0)]
    impl StorageReadImpl = storage_read_component::StorageRead<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        storage_read: storage_read_component::Storage,
        simple: felt252,
        mapping: LegacyMap<felt252, felt252>
    }


    #[external(v0)]
    impl TestContractImpl of super::ITestContract<ContractState> {
        fn write_simple(ref self: ContractState, value: felt252) {
            self.simple.write(value);
        }

        fn write_mapping(ref self: ContractState, key: felt252, value: felt252) {
            self.mapping.write(key, value);
        }
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StorageReadEvent: storage_read_component::Event
    }
}

fn deploy() -> (ITestContractDispatcher, IStorageReadDispatcher) {
    let (contract_address, _) = starknet::deploy_syscall(
        DummyContract::TEST_CLASS_HASH.try_into().unwrap(), 0, Default::default().span(), false
    )
        .unwrap_syscall();
    (ITestContractDispatcher { contract_address }, IStorageReadDispatcher { contract_address })
}

#[test]
#[available_gas(2000000)]
fn test_simple() {
    let (contract, reader) = deploy();
    let addr = 0x021b974e31e005ad301f0f7ef6ff3d756c261fe66213c0faa95f27c2befaed31
        .try_into()
        .unwrap();
    let before = reader.storage_read(0, addr);
    assert(before == 0, 'unexpected initial value');
    contract.write_simple('example');
    let after = reader.storage_read(0, addr);
    assert(after == 'example', 'unexpected final value');
}


#[test]
#[available_gas(2000000)]
fn test_mapping() {
    let (contract, reader) = deploy();
    let addr = 0x07436b353dfa1ef3a8652d368b0a6373f3f085988fa9db3543ba4b9a36c44612
        .try_into()
        .unwrap();
    let before = reader.storage_read(0, addr);
    assert(before == 0, 'unexpected initial value');
    contract.write_mapping(1, 'example2');
    let after = reader.storage_read(0, addr);
    assert(after == 'example2', 'unexpected final value');
}
