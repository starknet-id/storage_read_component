use starknet::storage_access::StorageAddress;

#[starknet::interface]
trait IStorageRead<TComponentState> {
    fn storage_read(
        self: @TComponentState, address_domain: u32, address: StorageAddress
    ) -> felt252;
}
