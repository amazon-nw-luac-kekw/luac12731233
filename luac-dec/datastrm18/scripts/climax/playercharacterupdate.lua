local PlayerCharacterUpdate = {
  Properties = {
    Character = {
      default = EntityId()
    }
  },
  customizableCharacterHandler = nil
}
function PlayerCharacterUpdate:OnActivate()
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
      self.entityBusHandler = EntityBus.Connect(self, self.Properties.Character)
    end
  end)
end
function PlayerCharacterUpdate:OnEntityActivated()
  if self.entityBusHandler then
    self.entityBusHandler:Disconnect()
    self.entityBusHandler = nil
  end
  self.meshIsReady = CustomizableCharacterRequestBus.Event.IsCharacterInstanceValid(self.Properties.Character)
  if self.meshIsReady then
    self:SetGender()
  else
    self.customizableCharacterHandler = CustomizableCharacterNotificationsBus.Connect(self, self.Properties.Character)
  end
end
function PlayerCharacterUpdate:SetGender()
  local gender = CustomizableCharacterRequestBus.Event.GetGender(self.playerEntityId)
  if gender == CustomizableCharacterRequestBus.Event.GetGender(self.Properties.Character) then
    self:OnSkinnedMeshCreated()
  else
    if self.customizableCharacterHandler == nil then
      self.customizableCharacterHandler = CustomizableCharacterNotificationsBus.Connect(self, self.Properties.Character)
    end
    CustomizableCharacterRequestBus.Event.SetGender(self.Properties.Character, gender)
  end
end
function PlayerCharacterUpdate:OnSkinnedMeshCreated()
  if not self.meshIsReady then
    self.meshIsReady = true
    self:SetGender()
  else
    CustomizableCharacterRequestBus.Event.SetRace(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetRace(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetHairstyle(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetHairstyle(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetFacialHair(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetFacialHair(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetSkinTone(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetSkinTone(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetFacialHairColor(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetFacialHairColor(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetHairColor(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetHairColor(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetFacialHairColor(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetFacialHairColor(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetEyeColor(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetEyeColor(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetFaceMark(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetFaceMark(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetScar(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetScar(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetTattoo(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetTattoo(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.SetTattooColor(self.Properties.Character, CustomizableCharacterRequestBus.Event.GetTattooColor(self.playerEntityId))
    CustomizableCharacterRequestBus.Event.UpdateEquipmentSlot(self.Properties.Character, "shirt", "LightChestT1", false, DyeData())
    CustomizableCharacterRequestBus.Event.UpdateEquipmentSlot(self.Properties.Character, "pants", "LightLegsT1", false, DyeData())
    if self.customizableCharacterHandler then
      self.customizableCharacterHandler:Disconnect()
      self.customizableCharacterHandler = nil
    end
  end
end
function PlayerCharacterUpdate:OnDeactivate()
end
return PlayerCharacterUpdate
