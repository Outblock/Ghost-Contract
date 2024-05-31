

access(all) contract GhostAccount {


  // declaration of a public variable
  access(all) let GhostAccountStoragePath: StoragePath
  access(all) let GhostAccountIdentityCertificatePath: StoragePath
  access(all) let GhostAccountPublicPath: PublicPath
  access(all) let LinkedAccountPath: StoragePath

  access(all) resource interface IdentityCertificate {}

  access(all) let authsMapping: {Address: [Address]}

  access(all) entitlement Owner




  access(all) event AuthGranted(address: Address, owner: Address)
  access(all) event AuthRevocked(address: Address, owner: Address)


  init(){
    let identifier = "AuthRecovery_".concat(self.account.address.toString())
    self.LinkedAccountPath = StoragePath(identifier: "LinkedAccountPrivatePath_".concat(identifier))!

    self.GhostAccountPublicPath = /public/ghostAccountRecorder
    self.GhostAccountStoragePath = /storage/ghostAccountRecorder
    self.GhostAccountIdentityCertificatePath = /storage/ghostAccountIdentityCertificate
    self.authsMapping = {}

    let account = self.account
    let recorder <- create AuthRecorder()
      
    self.account.storage.save(<-recorder, to: self.GhostAccountStoragePath)
    let authRecorderCap: Capability<&GhostAccount.AuthRecorder> = self.account.capabilities.storage.issue<&GhostAccount.AuthRecorder>(self.GhostAccountStoragePath)
    self.account.capabilities.publish(authRecorderCap, at: self.GhostAccountPublicPath)
  }

  access(all) resource AuthRecorder: IdentityCertificate {

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

    access(all) fun grantAuth(_ authAccountCap: Capability<auth(Keys) &Account>) {
      pre{
        self.hasAuth(address: authAccountCap!.address) == false : "Already granted"
        authAccountCap.borrow() != nil : "Account Cap can not be nil"
      }
      
      let toAddr = self.owner!.address
      let authAddr = authAccountCap!.address
      self.ownedAccounts[authAddr] = authAccountCap
      let authAddrs = GhostAccount.authsMapping[toAddr] ?? []
      
      authAddrs.append(authAddr)
      GhostAccount.authsMapping[toAddr] = authAddrs
      
      emit AuthGranted(address:authAddr, owner: self.owner!.address)
    }


    access(GhostAccount.Owner) fun getAuthAccount(_ addr: Address): auth(Keys) &Account {
      pre{
          self.ownedAccounts[addr] != nil : "cannot find authAccount"
      }
      let authAcctCap: Capability<auth(Keys) &Account> = self.ownedAccounts[addr]!
      return authAcctCap.borrow()!
    }

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
      let accts = GhostAccount.authsMapping[ownerAddr] ?? []
      let idx = accts.firstIndex(of: addr)!
      accts.remove(at: idx)
      GhostAccount.authsMapping[ownerAddr] = accts
      emit AuthRevocked(address: addr, owner: ownerAddr)
      return true
    }
  }


  access(all) view fun checkAuth(owner: Address, address: Address): Bool {
    let ownedAccts = GhostAccount.authsMapping[owner] ?? []
    return ownedAccts.contains(address)

  }
  
  access(all) fun createAuthRecorder(): @AuthRecorder {
    return <- create AuthRecorder()
  }

  access(all) view fun getOwnedAccount(_ address: Address): [Address]? {
    return self.authsMapping[address]
  }

}


 
