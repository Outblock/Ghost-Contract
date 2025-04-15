// GhostAccount contract manages delegated access to accounts with auth control and admin limits
access(all) contract GhostAccount {

    // Paths for storing and exposing the AuthRecorder and Admin resources
    access(all) let GhostAccountStoragePath: StoragePath
    access(all) let GhostAccountPublicPath: PublicPath
    access(all) let GhostAccountAdminStoragePath: StoragePath

    // Maximum number of accounts that can be authorized per AuthRecorder
    access(account) var authRecorderLimit: Int

    // Owner entitlement for restricted access
    access(all) entitlement Owner

    // Event emitted when an account is granted or revoked authorization
    access(all) event AuthChanged(address: Address, owner: Address, granted: Bool)

    // Contract initializer
    init() {
        self.GhostAccountPublicPath = /public/ghostAccountRecorder
        self.GhostAccountStoragePath = /storage/ghostAccountRecorder
        self.GhostAccountAdminStoragePath = /storage/ghostAccountAdminRecorder
        self.authRecorderLimit = 10

        // Create and store the initial AuthRecorder
        let recorder <- create AuthRecorder()
        self.account.storage.save(<-recorder, to: self.GhostAccountStoragePath)

        // Issue and publish a public capability to the AuthRecorder
        let authRecorderCap: Capability<&GhostAccount.AuthRecorder> =
            self.account.capabilities.storage.issue<&GhostAccount.AuthRecorder>(self.GhostAccountStoragePath)
        self.account.capabilities.publish(authRecorderCap, at: self.GhostAccountPublicPath)

        // Create and store the Admin resource
        self.account.storage.save(<-create Admin(), to: self.GhostAccountAdminStoragePath)
    }

    // Admin resource for managing contract-level settings
    access(all) resource Admin {
        init() {}

        // Allows the Owner to set a new authRecorderLimit
        access(GhostAccount.Owner) fun setGhostAccountAuthLimit(_ limit: Int) {
            GhostAccount.authRecorderLimit = limit
        }
    }

    // Resource that tracks and manages authorized accounts
    access(all) resource AuthRecorder {

        // Mapping of authorized addresses to their capabilities
        access(self) var ownedAccounts: {Address: Capability<auth(Keys) &Account>}

        init() {
            self.ownedAccounts = {}
        }

        // Returns a list of currently authorized addresses
        access(all) view fun getOwnedAccount(): [Address]? {
            return self.ownedAccounts.keys
        }

        // Checks if a given address is already authorized
        access(all) view fun hasAuth(address: Address): Bool {
            return self.ownedAccounts.containsKey(address)
        }

        // Grants authorization to a new account capability
        access(GhostAccount.Owner) fun grantAuth(_ authAccountCap: Capability<auth(Keys) &Account>) {
            pre {
                self.hasAuth(address: authAccountCap!.address) == false: "Already granted"
                authAccountCap.borrow() != nil: "Account Cap cannot be nil"
                self.getOwnedAccount()!.length < GhostAccount.authRecorderLimit: "Cannot exceed the limit of auth"
            }

            let toAddr = self.owner!.address
            let authAddr = authAccountCap!.address
            self.ownedAccounts[authAddr] = authAccountCap

            emit AuthChanged(address: authAddr, owner: toAddr, granted: true)
        }

        // Returns the authorized account capability, if available
        access(GhostAccount.Owner) fun getAuthAccount(_ addr: Address): auth(Keys) &Account? {
            let authAcctCap: Capability<auth(Keys) &Account>? = self.ownedAccounts[addr]
            if authAcctCap != nil {
                return authAcctCap!.borrow()
            } else {
                return nil
            }
        }

        // Adds a new key to an authorized account
        access(GhostAccount.Owner) fun addKey(
            _ addr: Address,
            key: PublicKey,
            hashAlgorithm: HashAlgorithm,
            weight: UFix64
        ) {
            pre {
                self.ownedAccounts[addr] != nil: "Cannot find authAccount"
            }

            let authAcctCap: Capability<auth(Keys) &Account> = self.ownedAccounts[addr]!
            let acct = authAcctCap.borrow()!

            acct.keys.add(
                publicKey: key,
                hashAlgorithm: hashAlgorithm,
                weight: weight
            )
        }

        // Revokes authorization from an account
        access(GhostAccount.Owner) fun revokeAuth(_ addr: Address): Bool {
            pre {
                self.ownedAccounts[addr] != nil: "Cannot find authAccount"
            }

            let ownerAddr = self.owner!.address
            self.ownedAccounts.remove(key: addr)

            emit AuthChanged(address: addr, owner: ownerAddr, granted: false)

            return true
        }
    }

    // Allows external users to create their own AuthRecorder
    access(all) fun createAuthRecorder(): @AuthRecorder {
        return <-create AuthRecorder()
    }
}
