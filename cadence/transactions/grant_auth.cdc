#allowAccountLinking
import "GhostAccount"

transaction() {
    prepare(signer: auth(Capabilities, StorageCapabilities, Keys, AddKey) &Account, owner: auth(Storage, BorrowValue) &Account) {

        let accountCap = signer.capabilities.account.issue<auth(Keys) &Account>()

        let authRecorderRef = owner.storage.borrow<auth(GhostAccount.Owner) &GhostAccount.AuthRecorder>(from: GhostAccount.GhostAccountStoragePath) ?? panic("Canot borrow Auth recorder")
        authRecorderRef.grantAuth(accountCap)
    }
}
