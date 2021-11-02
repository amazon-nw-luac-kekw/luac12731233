local AbilityCooldown = {
  Properties = {
    Cooldown1 = {
      default = EntityId()
    },
    Cooldown2 = {
      default = EntityId()
    },
    Cooldown3 = {
      default = EntityId()
    },
    Cover1 = {
      default = EntityId()
    },
    Cover2 = {
      default = EntityId()
    },
    Cover3 = {
      default = EntityId()
    }
  },
  desiredEnabledState = true
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AbilityCooldown)
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
function AbilityCooldown:OnInit()
  BaseElement.OnInit(self)
  self.isRadial = self.Cooldown1:IsRadial()
  if not self.isRadial then
    self.controllerHandler = DynamicBus.VerticalCooldownController.Connect(self.entityId, self)
  end
  self.keybindActionMap = "player"
  self.abilityCooldownTimerData = {
    [2894486750] = {
      keybind = "ability1",
      entityTable = self.Cooldown1,
      onEndSound = self.audioHelper.Meter_Full_Q,
      abilityIndex = 1,
      enableForDefaultWeapons = true
    },
    [898567524] = {
      keybind = "ability2",
      entityTable = self.Cooldown2,
      onEndSound = self.audioHelper.Meter_Full_R,
      abilityIndex = 2,
      enableForDefaultWeapons = true
    },
    [1116225010] = {
      keybind = "ability3",
      entityTable = self.Cooldown3,
      onEndSound = self.audioHelper.Meter_Full_F,
      abilityIndex = 3,
      enableForDefaultWeapons = false
    }
  }
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    self:BusConnect(CryActionNotificationsBus, abilityData.keybind)
    abilityData.entityTable:SetHint(abilityData.keybind, self.keybindActionMap, abilityData.onEndSound)
    abilityData.entityTable:SetIsVisible(false, 0, true)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableHudSettings", function(self, hudSettingsEnabled)
    self.hudSettingsEnabled = hudSettingsEnabled
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Video.HudShowAllWeapons", function(self, hudShowAllWeapons)
    if hudShowAllWeapons ~= nil then
      for _, abilityData in pairs(self.abilityCooldownTimerData) do
        abilityData.entityTable:SetIsShowingAllWeapons(hudShowAllWeapons)
      end
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Abilities.OnDataUpdate", function(self, onUpdate)
    if self.isEnabled and self.localSlotId then
      local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
      self:SetAbilitiesForItem(self.localSlotId, PaperdollRequestBus.Event.GetSlot(paperdollId, self.localSlotId))
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.ManaValue", function(self, manaValue)
    if manaValue then
      self.currentMana = manaValue
      self:UpdateAbilitiesDisabled()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.rootEntityId = rootEntityId
      self:BusConnect(CharacterAbilityNotificationBus, rootEntityId)
      CharacterAbilityRequestBus.Event.NotifyActiveInputsChanged(rootEntityId)
      self:SetCooldownsEnabled(self.desiredEnabledState)
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "CAGE.OnDisabledAbilityUsed", function(self, isEnterEvent)
    if isEnterEvent then
      local abilityId = self.dataLayer:GetDataFromNode("CAGE.OnDisabledAbilityUsed.Param")
      if abilityId then
        abilityId = Math.CreateCrc32(abilityId)
        for _, abilityData in pairs(self.abilityCooldownTimerData) do
          if abilityData.abilityId == abilityId then
            local flashIcon = true
            self:OnTryUseDisabledAbility(abilityData, flashIcon)
            return
          end
        end
      end
    end
  end)
end
function AbilityCooldown:OnShutdown()
  if self.controllerHandler then
    DynamicBus.VerticalCooldownController.Disconnect(self.entityId, self)
    self.controllerHandler = nil
  end
end
function AbilityCooldown:OnNumFreeCooldownsChangedByAbility(cooldownId, currentNumFreeCooldowns)
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    local abilityId = abilityData.abilityId
    if abilityId and abilityId == cooldownId then
      abilityData.numFreeCooldowns = currentNumFreeCooldowns
      abilityData.entityTable:SetNumFreeCooldowns(abilityData.numFreeCooldowns)
      return
    end
  end
end
function AbilityCooldown:OnSpellManaCostChangedByAbility(newAbility, affectedAbility)
  local manaChanged = false
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    local abilityId = abilityData.abilityId
    if abilityId then
      abilityData.manaCost = CharacterAbilityRequestBus.Event.GetEquippedAbilitySpellManaCost(self.rootEntityId, abilityId)
      manaChanged = true
      abilityData.numFreeCooldowns = CharacterAbilityRequestBus.Event.GetNumFreeCooldownsRemaining(self.rootEntityId, abilityId)
      abilityData.entityTable:SetNumFreeCooldowns(abilityData.numFreeCooldowns)
    end
  end
  if manaChanged then
    self:UpdateAbilitiesDisabled()
  end
end
function AbilityCooldown:SetCooldownsEnabled(isEnabled)
  self.desiredEnabledState = isEnabled
  if not self.rootEntityId then
    return
  end
  if self.isEnabled ~= isEnabled then
    if isEnabled then
      if not self.notificationHandler then
        self.notificationHandler = self:BusConnect(AbilityCooldownNotificationsBus)
        if self.rootEntityId then
          CharacterAbilityRequestBus.Event.NotifyActiveInputsChanged(self.rootEntityId)
        end
      end
    elseif self.notificationHandler then
      self:BusDisconnect(self.notificationHandler)
      self.notificationHandler = nil
    end
    self.isEnabled = isEnabled
  end
end
function AbilityCooldown:SetHintVisible(isVisible)
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    local isAbilityProgressionEnabled = abilityData.entityTable:GetIsAbilityProgressionEnabled()
    if not abilityData.enableForDefaultWeapons and not isAbilityProgressionEnabled then
      abilityData.entityTable:SetHintVisible(false)
    else
      abilityData.entityTable:SetHintVisible(isVisible)
    end
    abilityData.entityTable:SetCooldownTimerVisuals(not isVisible)
  end
end
function AbilityCooldown:SetCoversVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Cover1, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Cover2, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Cover3, isVisible)
end
function AbilityCooldown:OnAbilityTriggered(abilityId, cooldownTimeSeconds, isChanneled)
  if isChanneled then
    return
  end
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    if abilityData.abilityId == abilityId then
      local cooldownRemaining
      if self.isRadial then
        cooldownRemaining = DynamicBus.VerticalCooldownController.Broadcast.FindAbilityRemainingPercentage(abilityId)
        if cooldownRemaining == 0 then
          cooldownRemaining = nil
        end
      end
      abilityData.entityTable:SetTimer(cooldownTimeSeconds, cooldownRemaining)
      abilityData.numFreeCooldowns = CharacterAbilityRequestBus.Event.GetNumFreeCooldownsRemaining(self.rootEntityId, abilityData.abilityId)
      abilityData.entityTable:SetNumFreeCooldowns(abilityData.numFreeCooldowns)
      return
    end
  end
end
function AbilityCooldown:OnAbilityCooldownReset(abilityId)
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    if abilityData.abilityId == abilityId then
      abilityData.entityTable:ForceStopTimer()
      return
    end
  end
end
function AbilityCooldown:OnTryUseDisabledAbility(abilityData, flashIcon)
  abilityData.entityTable:FlashColor(self.UIStyle.COLOR_RED, true, true, flashIcon)
  self.audioHelper:PlaySound(self.audioHelper.Ability_On_Cooldown)
  if abilityData.requiresShield and not self:IsShieldEquipped() then
    local notificationData = NotificationData()
    notificationData.allowDuplicates = false
    notificationData.type = "Minor"
    notificationData.text = "@ui_cannot_use_shield_abilities"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  else
    DynamicBus.VitalsBus.Broadcast.OnVitalUseFailed(1624655410)
  end
end
function AbilityCooldown:OnCryAction(actionName, value)
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    if abilityData.keybind == actionName then
      if self.isActive and abilityData.isDisabled then
        self:OnTryUseDisabledAbility(abilityData)
      else
        local inCooldown = abilityData.abilityId and CooldownTimersComponentBus.Event.IsAbilityOnCooldown(self.rootEntityId, abilityData.abilityId)
        if inCooldown then
          abilityData.entityTable:FlashColor(self.UIStyle.COLOR_RED_DARK, false)
          self.audioHelper:PlaySound(self.audioHelper.Ability_On_Cooldown)
        end
      end
    end
  end
end
function AbilityCooldown:FindAbilityRemainingPercentage(abilityId)
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    if abilityData.abilityId == abilityId then
      return abilityData.entityTable:GetRemainingCooldownPercentage()
    end
  end
end
function AbilityCooldown:AbilityRequiresShield(activeAbility)
  return activeAbility.weaponTag == 2598749967 and activeAbility.treeId == 1
end
function AbilityCooldown:IsShieldEquipped()
  local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, ePaperDollSlotTypes_OffHandOption1)
  return slot and slot:IsValid() and slot:IsEquipped()
end
function AbilityCooldown:SetAbilitiesForItem(localSlotId, itemSlot)
  if not self.hudSettingsEnabled then
    return
  end
  if not itemSlot or not itemSlot:IsValid() then
    for _, abilityData in pairs(self.abilityCooldownTimerData) do
      UiElementBus.Event.SetIsEnabled(abilityData.entityTable.entityId, false)
    end
  else
    local supportsAbilityProgression = itemCommon:DoesItemSupportAbilityProgression(itemSlot:GetItemName())
    if supportsAbilityProgression then
      if self.rootEntityId then
        local activeAbilities = CharacterAbilityRequestBus.Event.GetActiveAbilityDataByItemSlot(self.rootEntityId, itemSlot)
        for _, abilityData in pairs(self.abilityCooldownTimerData) do
          local activeAbility = activeAbilities[abilityData.abilityIndex]
          local isEnabled = true
          if activeAbility then
            abilityData.entityTable:SetIcon(activeAbility.displayIcon, activeAbility.uiCategory)
            abilityData.entityTable:SetAbilityTooltipData(localSlotId, abilityData.abilityIndex)
            abilityData.requiresShield = self:AbilityRequiresShield(activeAbility)
            abilityData.abilityId = activeAbility.id
            abilityData.manaCost = CharacterAbilityRequestBus.Event.GetEquippedAbilitySpellManaCost(self.rootEntityId, abilityData.abilityId)
            abilityData.numFreeCooldowns = CharacterAbilityRequestBus.Event.GetNumFreeCooldownsRemaining(self.rootEntityId, abilityData.abilityId)
            isEnabled = self:IsAbilityEnabled(abilityData)
            abilityData.isDisabled = not isEnabled
          else
            abilityData.abilityId = nil
            abilityData.entityTable:SetIcon(nil)
            abilityData.numFreeCooldowns = 0
          end
          abilityData.entityTable:SetNumFreeCooldowns(abilityData.numFreeCooldowns)
          UiElementBus.Event.SetIsEnabled(abilityData.entityTable.entityId, true)
          abilityData.entityTable:SetDisabled(not isEnabled)
          abilityData.entityTable:SetIsAbilityProgressionEnabled(true)
        end
      end
    else
      for _, abilityData in pairs(self.abilityCooldownTimerData) do
        abilityData.entityTable:SetIcon(nil)
        UiElementBus.Event.SetIsEnabled(abilityData.entityTable.entityId, true)
        abilityData.entityTable:SetIsAbilityProgressionEnabled(false)
        abilityData.numFreeCooldowns = 0
        abilityData.entityTable:SetNumFreeCooldowns(abilityData.numFreeCooldowns)
      end
    end
  end
  self.localSlotId = localSlotId
end
function AbilityCooldown:UpdateAbilityTimers()
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    abilityData.entityTable:ForceStopTimer()
  end
  CooldownTimersComponentBus.Event.RequestUiUpdate(self.rootEntityId)
end
function AbilityCooldown:IsAbilityEnabled(abilityData)
  local manaCost = abilityData.manaCost or -1
  return manaCost < self.currentMana and (not abilityData.requiresShield or self:IsShieldEquipped())
end
function AbilityCooldown:UpdateAbilitiesDisabled()
  for _, abilityData in pairs(self.abilityCooldownTimerData) do
    local isDisabled = not self:IsAbilityEnabled(abilityData)
    abilityData.entityTable:SetDisabled(isDisabled)
    abilityData.isDisabled = isDisabled
  end
end
function AbilityCooldown:SetAbilitiesActive(isActive)
  self.isActive = isActive
end
return AbilityCooldown
