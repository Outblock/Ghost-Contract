#allowAccountLinking
import "GhostAccount"

transaction(publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64) {
    let authRecorderRef: auth(GhostAccount.Owner) &GhostAccount.AuthRecorder
    let authAccountCap: Capability<auth(Keys) &Account>

    prepare(signer: auth(BorrowValue, Storage) &Account) {
      
        let ownerAddr = signer.address
         let key = PublicKey(
            publicKey: publicKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgorithm)!
        )

        let account = Account(payer: signer)
        account.keys.add(
            publicKey: key,
            hashAlgorithm: HashAlgorithm(rawValue: hashAlgorithm)!,
            weight: weight
        )

        self.authRecorderRef = signer.storage.borrow<auth(GhostAccount.Owner) &GhostAccount.AuthRecorder>(from: GhostAccount.GhostAccountStoragePath) ?? panic("Canot borrow Auth recorder")

        self.authAccountCap = account.capabilities.account.issue<auth(Keys) &Account>()
        
    }

    execute {

        self.authRecorderRef.grantAuth(self.authAccountCap)

    }

}