import "GhostAccount"
import Crypto


transaction(address: Address, publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64) {
    prepare(signer: auth(BorrowValue) &Account) {
        let ownerAddr = signer.address
        let hasAuth = GhostAccount.checkAuth(owner: ownerAddr, address: address)
        assert(hasAuth==true, message: "Owner has no auth")
        let authRecorder = signer.storage.borrow<auth(GhostAccount.Owner) &GhostAccount.AuthRecorder>(from: GhostAccount.GhostAccountStoragePath) ?? panic("Canot borrow Auth recorder")

        let key = PublicKey(
            publicKey: publicKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgorithm)!
        )

        authRecorder.addKey(
            address,  
            key: key,
            hashAlgorithm: HashAlgorithm(rawValue: hashAlgorithm)!,
            weight: weight
        )
    }
   
}