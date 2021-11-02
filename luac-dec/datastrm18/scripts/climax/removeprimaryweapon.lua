local RemovePrimaryWeapon = {
  Properties = {
    entityToRemoveWeapon = {
      default = EntityId()
    }
  }
}
function RemovePrimaryWeapon:OnActivate()
  if self.Properties.entityToRemoveWeapon then
    PaperdollRequestBus.Event.RemovePrimaryWeapon(self.Properties.entityToRemoveWeapon)
  end
end
return RemovePrimaryWeapon
