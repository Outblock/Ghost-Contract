    
# test
# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=emulator-account ./cadence/transactions/set_up_ghost.cdc
# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=emulator-account ./cadence/transactions/create_account.cdc 25bda455f2f765a2375732e44ed34eb52a611b3b14607e43b2766c6c07a3f7b0abbd2fc38543f874cbaec50f53f0b6d685e85f78dbb5ffd81c66d9ba8c67b404 1 3 1000.0
# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=acc1 ./cadence/transactions/set_up_ghost.cdc

# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer='acc1' ./cadence/transactions/grant_auth.cdc 0xf8d6e0586b0a20c7

# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=emulator-account ./cadence/transactions/add_key_to_owned_account.cdc 0x179b6b1cb6755e31 25bda455f2f765a2375732e44ed34eb52a611b3b14607e43b2766c6c07a3f7b0abbd2fc38543f874cbaec50f53f0b6d685e85f78dbb5ffd81c66d9ba8c67b404 1 3 1000.0


flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=emulator-account ./cadence/transactions/create_account_and_grant_auth.cdc 25bda455f2f765a2375732e44ed34eb52a611b3b14607e43b2766c6c07a3f7b0abbd2fc38543f874cbaec50f53f0b6d685e85f78dbb5ffd81c66d9ba8c67b404 1 3 1000.0

# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=emulator-account ./cadence/transactions/add_key_to_owned_account.cdc 0xf3fcd2c1a78f5eee 25bda455f2f765a2375732e44ed34eb52a611b3b14607e43b2766c6c07a3f7b0abbd2fc38543f874cbaec50f53f0b6d685e85f78dbb5ffd81c66d9ba8c67b404 1 3 1000.0


# flow-c1 transactions build ./cadence/transactions/grant_auth.cdc  --proposer emulator-account --payer emulator-account --authorizer acc1 --authorizer emulator-account  --filter payload --save tx1 --network=emulator
# flow-c1 transactions sign tx1 --signer acc1 --filter payload --save tx2
# flow-c1 transactions sign tx2 --signer emulator-account --filter payload --save tx3
# flow-c1 transactions send-signed tx3 --network=emulator


# config

# flow-c1 transactions send --network=emulator --gas-limit=9999 --signer=emulator-account ./cadence/transactions/set_auth_limit.cdc 3
