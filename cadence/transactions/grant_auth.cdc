#allowAccountLinking
import "GhostAccount"

transaction(address: Address) {
    prepare(signer: auth(Storage, BorrowValue, Capabilities, StorageCapabilities, Keys, AddKey) &Account) {

        let ownerAcc = getAccount(address)

        let authRecorderRef = ownerAcc.capabilities.borrow<&GhostAccount.AuthRecorder>(GhostAccount.GhostAccountPublicPath) ?? panic("Could not borrow owner reference to the recipient's Auth recorder") 

        let accountCap = signer.capabilities.account.issue<auth(Keys) &Account>()

        authRecorderRef.grantAuth(accountCap)
       
    }
}
