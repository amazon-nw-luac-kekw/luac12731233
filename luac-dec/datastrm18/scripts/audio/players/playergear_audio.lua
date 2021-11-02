require("Scripts._Common.Common")
local foleyScriptLimiter = RequireScript("Scripts.Audio.NPCs.scriptLimiter_audio")
local PlayerGearScript = {
  Properties = {
    foleyEntities = {
      Head = EntityId(),
      Arm_L = EntityId(),
      Arm_R = EntityId(),
      Leg_L = EntityId(),
      Leg_R = EntityId()
    },
    scalar = {
      default = 1,
      description = "Number to multiply the distance by before setting as the RTPC value.",
      order = 2
    },
    LocalPlayerRoot = {
      default = EntityId(),
      description = "Root Player entity. Used to check if this slice is the local player",
      order = 3
    },
    PaperDollComponent = {
      default = EntityId(),
      description = "Entity that has the paper doll component. Used to get armor data.",
      order = 4
    }
  },
  CurrentEquipment = {}
}
function PlayerGearScript:OnActivate()
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.LocalPlayerRoot) then
    local isEditor = LyShineScriptBindRequestBus.Broadcast.IsEditor()
    if not isEditor then
      self:LocalEnable()
      self.debuggingOn = false
    else
      self:Enable()
    end
  else
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.LocalPlayerRoot)
    AudioTriggerComponentRequestBus.Event.SetObstructionType(self.Properties.LocalPlayerRoot, eAudioObstructionType_SingleRay)
  end
  foleyScriptLimiter:OnActivate()
end
function PlayerGearScript:LocalEnable()
  if self.playerSpawningBusHandler == nil then
    self.playerSpawningBusHandler = DynamicBus.playerSpawningBus.Connect(self.entityId, self)
  end
  self.playerRemote = false
end
function PlayerGearScript:RemoteEnable()
  if not foleyScriptLimiter:CanActivateMore() then
    return
  end
  foleyScriptLimiter:Activated()
  self.foleyLimiterActive = true
  self.playerRemote = true
  self:Enable()
end
function PlayerGearScript:postPlayerSpawn(bool)
  self:Enable()
end
function PlayerGearScript:Enable()
  self.isEnabled = true
  if self.paperDollHandler == nil then
    self.paperDollHandler = PaperdollEventBus.Connect(self, self.Properties.PaperDollComponent)
  end
  if self.tickBusHandler == nil then
    self.tickBusHandler = TickBus.Connect(self)
  end
  self.localTranslation = {}
  self.lastFrameTranslation = {}
  self.CurrentEquipment[ePaperDollSlotTypes_Head] = ""
  self.CurrentEquipment[ePaperDollSlotTypes_Chest] = ""
  self.CurrentEquipment[ePaperDollSlotTypes_Hands] = ""
  self.CurrentEquipment[ePaperDollSlotTypes_Legs] = ""
  self.CurrentEquipment[ePaperDollSlotTypes_Feet] = ""
  self:EnableEquipment()
end
function PlayerGearScript:EnableEquipment()
  local slot = PaperdollRequestBus.Event.GetSlot(self.Properties.PaperDollComponent, 0)
  if slot ~= nil then
    self:UpdateFoley(ePaperDollSlotTypes_Head, slot)
  elseif self.debuggingOn then
    Debug.Log("##### No outfit on HEAD")
  end
  slot = PaperdollRequestBus.Event.GetSlot(self.Properties.PaperDollComponent, 1)
  if slot ~= nil then
    self:UpdateFoley(ePaperDollSlotTypes_Chest, slot)
  elseif self.debuggingOn then
    Debug.Log("##### No outfit on CHEST")
  end
  slot = PaperdollRequestBus.Event.GetSlot(self.Properties.PaperDollComponent, 2)
  if slot ~= nil then
    self:UpdateFoley(ePaperDollSlotTypes_Hands, slot)
  elseif self.debuggingOn then
    Debug.Log("##### No outfit on HANDS")
  end
  slot = PaperdollRequestBus.Event.GetSlot(self.Properties.PaperDollComponent, 3)
  if slot ~= nil then
    self:UpdateFoley(ePaperDollSlotTypes_Legs, slot)
  elseif self.debuggingOn then
    Debug.Log("##### No outfit on LEGS")
  end
  slot = PaperdollRequestBus.Event.GetSlot(self.Properties.PaperDollComponent, 4)
  if slot ~= nil then
    self:UpdateFoley(ePaperDollSlotTypes_Feet, slot)
  elseif self.debuggingOn then
    Debug.Log("##### No outfit on FEET")
  end
end
function PlayerGearScript:OnTriggerAreaEntered(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer(entityId) then
    self:RemoteEnable()
  end
end
function PlayerGearScript:OnTriggerAreaExited(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer(entityId) then
    self:Disable()
  end
end
function PlayerGearScript:OnDeactivate()
  self:Disable()
  if self.triggerAreaBusHandler then
    self.triggerAreaBusHandler:Disconnect()
  end
end
function PlayerGearScript:Disable()
  if self.isEnabled then
    if self.paperDollHandler ~= nil then
      self.paperDollHandler:Disconnect()
      self.paperDollHandler = nil
    end
    if self.tickBusHandler ~= nil then
      self.tickBusHandler:Disconnect()
      self.tickBusHandler = nil
    end
    self:DisableEquipment()
    if self.foleyLimiterActive then
      foleyScriptLimiter:Deactivated()
    end
    self.isEnabled = false
  end
end
function PlayerGearScript:DisableEquipment()
  local numEquipmentSlots = CountAssociativeTable(self.CurrentEquipment)
  for i = 0, numEquipmentSlots do
    self:UnequipItem(i)
  end
end
function PlayerGearScript:OnPaperdollSlotUpdate(slot, item, action)
  if slot > ePaperDollSlotTypes_Feet then
    return
  end
  self:UpdateFoley(slot, item)
end
function PlayerGearScript:UnequipItem(slot)
  local data = ArmorAudioData()
  local playerGender = CustomizableCharacterRequestBus.Event.GetGender(self.Properties.LocalPlayerRoot)
  ItemDataManagerBus.Broadcast.GetArmorAudioData(Math.CreateCrc32(self.CurrentEquipment[slot]), playerGender, data)
  if not data:IsValid() and self.CurrentEquipment[slot] ~= nil then
    Debug.Error("Cannot get armor audio data for " .. self.CurrentEquipment[slot])
    return
  end
  self:UpdateFoleyItem(slot, data, false)
  self.CurrentEquipment[slot] = ""
end
function PlayerGearScript:UpdateFoleyItem(slot, data, isEquip)
  if isEquip then
    triggerPrefix = "Play_"
  else
    triggerPrefix = "Stop_"
  end
  if slot == ePaperDollSlotTypes_Head then
    if isEquip then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.foleyEntities.Head, data.leftOnAudioTrigger)
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.LocalPlayerRoot, "fly_switch_helmet", "On")
    else
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.foleyEntities.Head, data.rightOffAudioTrigger)
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.LocalPlayerRoot, "fly_switch_helmet", "Off")
    end
  elseif slot == ePaperDollSlotTypes_Chest then
    if data.leftOnAudioTrigger ~= "" then
      if isEquip then
        local armorString = tostring(string.sub(data.leftOnAudioTrigger, 5, -7))
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.LocalPlayerRoot, "fly_type_chest", armorString)
      else
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.LocalPlayerRoot, "fly_type_chest", "Naked")
      end
      self:ExecuteSoundUpdate(isEquip, triggerPrefix, data.leftOnAudioTrigger, self.Properties.foleyEntities.Arm_L)
    end
    if data.rightOffAudioTrigger ~= "" then
      self:ExecuteSoundUpdate(isEquip, triggerPrefix, data.rightOffAudioTrigger, self.Properties.foleyEntities.Arm_R)
    end
  elseif slot == ePaperDollSlotTypes_Legs then
    if data.leftOnAudioTrigger ~= "" then
      if isEquip then
        local armorString = tostring(string.sub(data.leftOnAudioTrigger, 5, -7))
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.LocalPlayerRoot, "fly_type_chest", armorString)
      else
        AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.LocalPlayerRoot, "fly_type_legs", "Naked")
      end
      self:ExecuteSoundUpdate(isEquip, triggerPrefix, data.leftOnAudioTrigger, self.Properties.foleyEntities.Leg_L)
    end
    if data.rightOffAudioTrigger ~= "" then
      self:ExecuteSoundUpdate(isEquip, triggerPrefix, data.rightOffAudioTrigger, self.Properties.foleyEntities.Leg_R)
    end
  end
end
function PlayerGearScript:ExecuteSoundUpdate(isEquip, triggerPrefix, audioTrigger, foleyEntity)
  if isEquip then
    AudioPreloadComponentRequestBus.Event.LoadPreload(foleyEntity, audioTrigger)
    if self.playerRemote then
      AudioTriggerComponentRequestBus.Event.SetObstructionType(foleyEntity, eAudioObstructionType_SingleRay)
    else
      AudioProxyComponentRequestBus.Event.SetTransformTolerance(foleyEntity, 0)
    end
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(foleyEntity, triggerPrefix .. audioTrigger)
  else
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(foleyEntity, triggerPrefix .. audioTrigger)
    AudioPreloadComponentRequestBus.Event.UnloadPreload(foleyEntity, audioTrigger)
  end
end
function PlayerGearScript:UpdateFoley(slot, item)
  if item == nil or item:GetItemName() == "" then
    if self.CurrentEquipment[slot] ~= "" then
      self:UnequipItem(slot)
    end
    return
  end
  local currentArmor = self.CurrentEquipment[slot]
  local armorName = item:GetItemName()
  if item:IsBroken() then
    self:UnequipItem(slot)
    return
  end
  if armorName == currentArmor then
    return
  elseif armorName ~= "" then
    if self.CurrentEquipment[slot] ~= "" then
      self:UnequipItem(slot)
    end
    local data = ArmorAudioData()
    local playerGender = CustomizableCharacterRequestBus.Event.GetGender(self.Properties.LocalPlayerRoot)
    ItemDataManagerBus.Broadcast.GetArmorAudioData(Math.CreateCrc32(armorName), playerGender, data)
    if not data:IsValid() then
      Debug.Error("Cannot get armor audio data for " .. armorName)
      return
    end
    self:UpdateFoleyItem(slot, data, true)
    self.CurrentEquipment[slot] = armorName
  end
end
function PlayerGearScript:OnTick(deltaTime, timePoint)
  for idx, foleyEntityId in pairs(self.Properties.foleyEntities) do
    if foleyEntityId ~= nil then
      self.localTranslation[idx] = TransformBus.Event.GetLocalTranslation(foleyEntityId)
      if not self.lastFrameTranslation[idx] then
        self.lastFrameTranslation[idx] = self.localTranslation[idx]
        return
      end
      if self.localTranslation[idx] ~= nil and self.lastFrameTranslation[idx] ~= nil then
        local deltaTranslation = self.localTranslation[idx] - self.lastFrameTranslation[idx]
        local deltaDistance = Vector3.GetLength(deltaTranslation) * self.Properties.scalar
        local rtpcValue = deltaDistance / deltaTime
        AudioRtpcComponentRequestBus.Event.SetValue(foleyEntityId, rtpcValue)
        self.lastFrameTranslation[idx] = self.localTranslation[idx]
      end
    end
  end
end
return PlayerGearScript
