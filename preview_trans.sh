    
# testnet
# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=test1 ./cadence/transactions/set_up_ghost.cdc
# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=test2 ./cadence/transactions/set_up_ghost.cdc
# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=preview ./cadence/transactions/create_account.cdc 935c983f95f8b871b7071442ef614c6d3295a5fffd0e0fb2b9fac11da88638d20526822f2f3f7881f2618af00d784a90292ceed8a9ccc6ae346890d1283df9da 1 3 1000.0
# flow-c1 transactions send --network=previewnet --gas-limit=9999 --signer=preview ./cadence/transactions/create_account_and_grant_auth.cdc 0x104505db008b54c9 935c983f95f8b871b7071442ef614c6d3295a5fffd0e0fb2b9fac11da88638d20526822f2f3f7881f2618af00d784a90292ceed8a9ccc6ae346890d1283df9da 1 3 1000.0



# flow-c1 transactions send --network=previewnet --gas-limit=9999 --signer=preview ./cadence/transactions/add_key_to_owned_account.cdc 0x061160e8998f5ea8 935c983f95f8b871b7071442ef614c6d3295a5fffd0e0fb2b9fac11da88638d20526822f2f3f7881f2618af00d784a90292ceed8a9ccc6ae346890d1283df9da 1 3 1000.0


# flow-c1 transactions send --network=previewnet --gas-limit=9999 --signer=test2 ./cadence/transactions/grant_auth.cdc 0x104505db008b54c9
flow-c1 transactions send --network=previewnet --gas-limit=9999 --signer=preview ./cadence/transactions/add_key_to_owned_account.cdc 0xe276d93588755e77 935c983f95f8b871b7071442ef614c6d3295a5fffd0e0fb2b9fac11da88638d20526822f2f3f7881f2618af00d784a90292ceed8a9ccc6ae346890d1283df9da 1 3 1000.0
