#allowAccountLinking
import "GhostAccount"

transaction(owner: Address, publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64) {
    prepare(signer:auth(BorrowValue | Storage) &Account) {
      
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

        let ownerAcc = getAccount(owner)
        let authRecorderRef = ownerAcc.capabilities.borrow<&GhostAccount.AuthRecorder>(GhostAccount.GhostAccountPublicPath) ?? panic("Could not borrow owner reference to the recipient's Auth recorder") 

        let accountKeyCap = account.capabilities.account.issue<auth(Keys) &Account>()
        authRecorderRef.grantAuth(accountKeyCap)

    }

}