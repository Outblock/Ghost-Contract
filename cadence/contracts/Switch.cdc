

access(all) contract Switch {


  // declaration of a public variable
  access(all) let SwitchStoragePath: StoragePath
  access(all) let SwitchAdminStoragePath: StoragePath
  access(all) let SwitchPublicPath: PublicPath

  access(self) var gracePeriod : UFix64


  access(all) entitlement Owner


  access(all) event Added(address: Address, owner: Address)
  access(all) event Removed(address: Address, owner: Address)
  access(all) event GracePeriodUpdated(before: UFix64, after: UFix64)
  access(all) event AccountActived(before: UFix64, after: UFix64)


  init(){

    self.SwitchPublicPath = /public/switchRecorder
    
    self.SwitchStoragePath = /storage/switchRecorder
    self.SwitchAdminStoragePath = /storage/switchAdminRecorder
      
    self.gracePeriod = 86400000.00
    let account = self.account
   
    self.account.storage.save(<- create Admin(), to: self.SwitchAdminStoragePath)
  }

  access(all) resource Admin {
    
    init () {
      
    }

    access(Switch.Owner) fun setGracePeriod(_ period: UFix64) {
      emit GracePeriodUpdated(before: Switch.gracePeriod, after: period)
      Switch.gracePeriod = period
    }

  }

  access(all) resource SwitchRecorder {

    access(self) var beneficiaries: [Address]?
    access(self) var expiredTime: UFix64
    access(self) var authAccount: &Account

    init (_ authAccount: &Account) {
      self.beneficiaries = []
      self.expiredTime = getCurrentBlock().timestamp + Switch.gracePeriod
      self.authAccount = authAccount
    }


    access(all) view fun getExpiredTime(): UFix64 {
      return self.expiredTime
    }


    access(all) view fun getBeneficiaries(): [Address]? {
      return self.beneficiaries
    }

    access(all) view fun isBeneficiary(_ address: Address): Bool {
      return self.beneficiaries!.contains(address)
    }

    access(Switch.Owner) fun activeAccount() {

      let newExpiredTime = getCurrentBlock().timestamp + Switch.gracePeriod
      emit GracePeriodUpdated(before: self.expiredTime, after: newExpiredTime)
      self.expiredTime = newExpiredTime

    }

    access(Switch.Owner) fun addBeneficiary(_ addr: Address) {
      pre{
        self.isBeneficiary(addr) == false : "Already exist"
      }
      self.beneficiaries!.append(addr)
      emit Added(address:addr, owner: self.owner!.address)
    }


    access(Switch.Owner) fun removeBeneficiary(_ addr: Address): Bool {
      pre{
          self.isBeneficiary(addr) == true : "cannot find beneficiary"
      }
      let ownerAddr = self.owner!.address

      let idx = self.beneficiaries!.firstIndex(of: addr)!
      self.beneficiaries!.remove(at: idx)
      emit Removed(address: addr, owner: ownerAddr)
      return true
    }
  }
  
  access(all) fun createSwitchRecorder(authAccount: &Account): @SwitchRecorder {
    return <- create SwitchRecorder(authAccount)
  }

  access(all) view fun getGracePeriod(): UFix64 {
    return self.gracePeriod
  }


}


 
