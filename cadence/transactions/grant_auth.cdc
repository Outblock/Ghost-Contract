import "GhostAccount"

transaction(address: Address) {
    prepare(signer: auth(Storage, BorrowValue, Capabilities, StorageCapabilities, Keys, AddKey) &Account) {

        let ownerAcc = getAccount(address)

        let authRecorderRef = ownerAcc.capabilities.borrow<&GhostAccount.AuthRecorder>(GhostAccount.GhostAccountPublicPath) ?? panic("Could not borrow owner reference to the recipient's Auth recorder") 

        let accountCap = signer.capabilities.storage.issue<auth(Keys) &Account>(GhostAccount.LinkedAccountPath)

        authRecorderRef.grantAuth(accountCap)
       
    }
}
