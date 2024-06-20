#allowAccountLinking
import "GhostAccount"

transaction(address: Address) {
    prepare(signer: auth(Storage, BorrowValue) &Account) {

        let authRecorderRef = signer.storage.borrow<auth(GhostAccount.Owner) &GhostAccount.AuthRecorder>(from: GhostAccount.GhostAccountStoragePath) ?? panic("Canot borrow Auth recorder")
        authRecorderRef.revokeAuth(address)
    }
}
