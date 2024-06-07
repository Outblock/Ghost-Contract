import "GhostAccount"

transaction {
    prepare(signer: auth(Storage, BorrowValue, Capabilities, StorageCapabilities) &Account) {

        if signer.storage.borrow<&GhostAccount.AuthRecorder>(from: GhostAccount.GhostAccountStoragePath) == nil {
            let recorder <- GhostAccount.createAuthRecorder()
            signer.storage.save(<-recorder, to: GhostAccount.GhostAccountStoragePath)
        }

        if signer.capabilities.exists(GhostAccount.GhostAccountPublicPath) == false {
            let authRecorderCap: Capability<&GhostAccount.AuthRecorder> = signer.capabilities.storage.issue<&GhostAccount.AuthRecorder>(GhostAccount.GhostAccountStoragePath)
            signer.capabilities.publish(authRecorderCap, at: GhostAccount.GhostAccountPublicPath)
        }
    }
}
