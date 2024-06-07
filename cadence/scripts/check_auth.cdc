import "GhostAccount"

access(all)
fun main(owner: Address, address: Address): Bool {
    let account = getAccount(owner)
    let authRecorderRef = account.capabilities.borrow<&GhostAccount.AuthRecorder>(GhostAccount.GhostAccountPublicPath) ?? panic("Could not borrow owner reference to the recipient's Auth recorder") 
    return authRecorderRef.hasAuth(address: address)
}
