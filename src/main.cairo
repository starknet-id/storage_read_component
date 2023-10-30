#[starknet::component]
mod storage_read_component {
    use starknet::{storage_access::StorageAddress, SyscallResultTrait};
    use storage_read::interface::IStorageRead;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[embeddable_as(StorageRead)]
    impl StorageReadImpl<
        TContractState, +HasComponent<TContractState>
    > of IStorageRead<ComponentState<TContractState>> {
        fn storage_read(
            self: @ComponentState<TContractState>, address_domain: u32, address: StorageAddress
        ) -> felt252 {
            starknet::storage_read_syscall(address_domain, address).unwrap_syscall()
        }
    }
}
