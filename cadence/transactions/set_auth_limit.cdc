// read more about Cadence transactions here https://developers.flow.com/cadence/language/transactions
import "GhostAccount"

transaction(limit: Int) {

    prepare(signer: auth(Storage, BorrowValue) &Account) {
        let adminRef = signer.storage.borrow<auth(GhostAccount.Owner) &GhostAccount.Admin>(from: GhostAccount.GhostAccountAdminStoragePath) ?? panic("Canot borrow admin recorder")
        adminRef.setGhostAccountAuthLimit(limit)
    }
}
