

access(all) contract GhostAccount {

  access(all) let GhostAccountStoragePath: StoragePath
  access(all) let GhostAccountPublicPath: PublicPath
  access(all) let GhostAccountAdminStoragePath: StoragePath

  // AuthRecorder limit 
  access(account) var authRecorderLimit: Int

  access(all) entitlement Owner

  access(all) event AuthGranted(address: Address, owner: Address)
  access(all) event AuthRevocked(address: Address, owner: Address)


  init(){
    self.GhostAccountPublicPath = /public/ghostAccountRecorder
    self.GhostAccountStoragePath = /storage/ghostAccountRecorder
    self.GhostAccountAdminStoragePath = /storage/ghostAccountAdminRecorder
    self.authRecorderLimit = 10
      
    let account = self.account
    let recorder <- create AuthRecorder()


    self.account.storage.save(<-recorder, to: self.GhostAccountStoragePath)
    let authRecorderCap: Capability<&GhostAccount.AuthRecorder> = self.account.capabilities.storage.issue<&GhostAccount.AuthRecorder>(self.GhostAccountStoragePath)
    self.account.capabilities.publish(authRecorderCap, at: self.GhostAccountPublicPath)

    // create admin resource
    self.account.storage.save(<- create Admin(), to: self.GhostAccountAdminStoragePath)
  }

  access(all) resource Admin {
    init () {}

    // change limit of AuthRecorder 
    access(GhostAccount.Owner) fun setGhostAccountAuthLimit(_ limit: Int) {
      GhostAccount.authRecorderLimit = limit
    }
  }

  // For record the primary AuthAccount auth(Keys) in ownedAccounts
  access(all) resource AuthRecorder {
    access(self) var ownedAccounts: {Address: Capability<auth(Keys) &Account>}

    init () {
      self.ownedAccounts = {}
    }

    access(all) view fun getOwnedAccount(): [Address]? {
      return self.ownedAccounts.keys
    }

    access(all) view fun hasAuth(address: Address): Bool {
      return self.ownedAccounts.containsKey(address)
    }

    // Grant auth need multi-sig trx to add record on ownedAccounts
    access(GhostAccount.Owner) fun grantAuth(_ authAccountCap: Capability<auth(Keys) &Account>) {
      pre{
        self.hasAuth(address: authAccountCap!.address) == false : "Already granted"
        authAccountCap.borrow() != nil : "Account Cap can not be nil"
        self.getOwnedAccount()!.length < GhostAccount.authRecorderLimit : "Can not exceed the limit of auth"
      }
      
      let toAddr = self.owner!.address
      let authAddr = authAccountCap!.address
      self.ownedAccounts[authAddr] = authAccountCap
      emit AuthGranted(address:authAddr, owner: self.owner!.address)
    }

    // Get auth record to revoke key or add keys
    access(GhostAccount.Owner) fun getAuthAccount(_ addr: Address): auth(Keys) &Account {
      pre{
          self.ownedAccounts[addr] != nil : "cannot find authAccount"
      }
      let authAcctCap: Capability<auth(Keys) &Account> = self.ownedAccounts[addr]!
      return authAcctCap.borrow()!
    }

    // Add new key on owned AuthAccount
    access(GhostAccount.Owner) fun addKey(_ addr: Address, key: PublicKey, hashAlgorithm: HashAlgorithm, weight: UFix64) {
      pre{
          self.ownedAccounts[addr] != nil : "cannot find authAccount"
      }
      let authAcctCap: Capability<auth(Keys) &Account> = self.ownedAccounts[addr]!
      let acct = authAcctCap.borrow()!
      
      acct.keys.add(
          publicKey: key,
          hashAlgorithm: hashAlgorithm,
          weight: weight
      )
    }


    access(GhostAccount.Owner) fun revokeAuth(_ addr: Address): Bool {
      pre{
          self.ownedAccounts[addr] != nil : "cannot find authAccount"
      }
      let ownerAddr = self.owner!.address
      self.ownedAccounts.remove(key: addr)
      emit AuthRevocked(address: addr, owner: ownerAddr)
      return true
    }
  }
  
  // create AuthRecorder for user who wants GhostAccount
  access(all) fun createAuthRecorder(): @AuthRecorder {
    return <- create AuthRecorder()
  }

}


 
