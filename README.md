# Ghost Account

GhostAccount is to solve the problem of creating and backup multiple accounts in Flow network. 
Currently, Flow wallet uses Secure enclaves to help users manage private keys, and provides multiple backup solutions such as Apple iCloud and Google Drive. In the single account mode, it takes into account security and convenience.

When the wallet supports multiple accounts, some unavoidable problems will arise. For example, if a user wants to manage multiple Flow addresses in the wallet, in the original mechanism, multiple backups are needed for each account, because the creation of an address in the Flow network is not calculated through an encryption algorithm based on a private key, but an unpredictable address generated in the network, which cannot be achieved through a multi-account model similar to a derived path.

On this basis, in order to minimize the difficulty for users to backup private keys and recover accounts without compromising security levels, we designed the GhostAccount contract to help users better manage multi-address backups and account retrieval.

![Image](https://trello.com/1/cards/65645b4a52652f824458950f/attachments/667294a168cf6b0508e9466f/download/image.png)

## More detail

The Ghost Account is basically a normal Flow address, created through Flow wallet, that interacts with the GhostAccount contract, initializing a `AuthRecorder` resource through the contract, this resource can hold references to the `auth(Keys) &Account` type of other new accounts. 
Ghost Account is a secure Ghost Account with permissions to manage multiple address Keys. In this way, the user can only manage and back up the private key of the Ghost Account, which can ensure the security of all accounts, and can easily recover the ownership of an Account by reproducing the `AuthRecorder` to record the permissions.

There are some permissions issues to consider here. For example, the `AuthRecorder` resource requires multiple authorizations for the Ghost Account owner and the new Account to grant the `auth(Keys) &Account` reference to the new Account. To avoid some malicious attacks and abuse. In addition, the `AuthRecorder` resource can only be called by the owner of Ghost Account by the entitlement restriction, which ensures the security of Account recovery.

## Workflow
The authorization process:

New User Registration:
- generate the Ghost Account and back up the private key/mnemonic
- initialize the `AuthRecorder` resource in the Ghost Account contract
- build the multi-sign transaction in the script that creates the new Account and deposit the new Account's `auth(Keys) &Account` by transaction into the Ghost Account's `AuthRecorder` resource
- complete authorization

Upgrade for old users
- generate the Ghost Account and back up the private key/mnemonic
- initialize the `AuthRecorder` resource in the Ghost Account Contract
- build the authorization multi-sign transaction directly and grant the `auth(Keys) &Account` of the existing address into the `AuthRecorder` resource of the Ghost account

Keys recovery is typically used in cases where an authorized account has been stolen or lost
- restore Ghost Account by wallet
- build transaction to borrow the `AuthRecorder` , get `auth(Keys) &Account` from the `AuthRecorder`  resource and add new Keys to the address