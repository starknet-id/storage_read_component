use starknet::storage_access::StorageAddress;

#[starknet::interface]
trait IStorageRead<TContractState> {
    fn storage_read(self: @TContractState, address_domain: u32, address: StorageAddress) -> felt252;
}
