import "GhostAccount"

access(all)
fun main(owner: Address): [Address]? {
    return GhostAccount.getOwnedAccount(owner)
}
