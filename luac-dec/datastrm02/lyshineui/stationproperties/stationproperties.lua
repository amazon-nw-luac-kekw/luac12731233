local StationProperties = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    PermissionsText = {
      default = EntityId()
    },
    PermissionsDropdown = {
      default = EntityId()
    },
    OutpostDisplay = {
      default = EntityId()
    },
    OutpostNameText = {
      default = EntityId()
    },
    CustomNameContainer = {
      default = EntityId()
    },
    CustomNameTextInput = {
      default = EntityId()
    },
    CustomNameText = {
      default = EntityId()
    },
    EditCustomNameButton = {
      default = EntityId()
    }
  },
  IconPathRoot = "lyshineui/images/icons/items/",
  focusedEntityInfo = nil,
  uiInteractorComponentNotificationsHandler = nil,
  uiVitalsHandler = nil,
  currentWalletAmount = 0,
  spaceBetweenWalletAndSkill = 20,
  outpostList = {}
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(StationProperties)
function StationProperties:OnInit()
  BaseScreen.OnInit(self)
  self.SignUpScreenCRC = 1319313135
  self.PermissionsDropdown:SetCallback("OnPermissionChanged", self)
  self.PermissionsDropdown:SetDropdownScreenCanvasId(self.PermissionsDropdown.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InteractorEntityId", function(self, data)
    self.interactorId = data
    self:BusDisconnect(self.uiInteractorComponentNotificationsHandler)
    if data ~= nil then
      self.uiInteractorComponentNotificationsHandler = self:BusConnect(UiInteractorComponentNotificationsBus, data)
    end
  end)
  local TradeSkillsCommon = RequireScript("LyShineUI._Common.TradeSkillsCommon")
  self.skillDisplayStructures = {}
  self.skillDisplayStructures.Alchemy = TradeSkillsCommon:GetTradeSkillDataFromTableId(1345659118)
  self.skillDisplayStructures.Blacksmith = TradeSkillsCommon:GetTradeSkillDataFromTableId(3463856138)
  self.skillDisplayStructures.Cooking = TradeSkillsCommon:GetTradeSkillDataFromTableId(1182525034)
  self.skillDisplayStructures.Engineering = TradeSkillsCommon:GetTradeSkillDataFromTableId(242652078)
  self.skillDisplayStructures.Outfitting = TradeSkillsCommon:GetTradeSkillDataFromTableId(50620476)
  self.skillDisplayStructures.Carpentry = TradeSkillsCommon:GetTradeSkillDataFromTableId(2617220015)
  self.skillDisplayStructures.Masonry = TradeSkillsCommon:GetTradeSkillDataFromTableId(749528765)
  self.skillDisplayStructures.Smelting = TradeSkillsCommon:GetTradeSkillDataFromTableId(580130092)
  self.skillDisplayStructures.Tanning = TradeSkillsCommon:GetTradeSkillDataFromTableId(1929694176)
  self.skillDisplayStructures.Weaving = TradeSkillsCommon:GetTradeSkillDataFromTableId(1764904178)
  self.secondarySkills = {
    Engineering = TradeSkillsCommon:GetTradeSkillDataFromTableId(2953732754),
    Outfitting = TradeSkillsCommon:GetTradeSkillDataFromTableId(2853394152),
    Blacksmith = TradeSkillsCommon:GetTradeSkillDataFromTableId(50620476)
  }
  self.tertiarySkills = {
    Blacksmith = TradeSkillsCommon:GetTradeSkillDataFromTableId(242652078)
  }
  self.permissionsDisplayStructures = {
    Alchemy = true,
    AnimalPen = true,
    AzureWell = true,
    Blacksmith = true,
    Carpentry = true,
    Cooking = true,
    Dwelling = true,
    Engineering = true,
    Farm = true,
    Masonry = true,
    Outfitting = true,
    Outhouse = true,
    Smelting = true,
    Storage = true,
    Tanning = true,
    Weaving = true,
    Well = true
  }
  self.walletStructures = {
    Alchemy = true,
    Blacksmith = true,
    Camp = true,
    Cooking = true,
    Engineering = true,
    Outfitting = true,
    Carpentry = true,
    Masonry = true,
    Smelting = true,
    Tanning = true,
    Weaving = true,
    TradingPost = true
  }
  DynamicBus.StationPropertiesBus.Connect(self.entityId, self)
end
function StationProperties:OnInteractFocus(onFocus)
  self.focusedEntityInfo = {
    vitalsStatEntityId = onFocus:GetHealthBind().vitalsStatBindEntityId,
    ownershipBindEntityId = onFocus:GetOwnershipBind().ownershipBindEntityId,
    supportsCustomName = onFocus.supportsCustomName
  }
end
function StationProperties:OnInteractExecute(onExecute)
end
function StationProperties:Update()
  if not self.focusedEntityInfo then
    return false
  end
  local interactName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.InteractName")
  local displayName = interactName
  local ownershipEntityId = self.focusedEntityInfo.ownershipBindEntityId
  if ownershipEntityId:IsValid() then
    local customName = OwnershipRequestBus.Event.GetGuildStructureName(ownershipEntityId)
    if customName and customName ~= "" then
      displayName = customName
    end
  end
  if displayName then
    local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_stationName", displayName)
    self.ScreenHeader:SetText(text, true)
    self.displayName = displayName
  end
  local structureName
  local index = string.find(interactName, "_")
  if index ~= nil then
    structureName = string.sub(string.sub(interactName, 1, index - 1), 2)
  end
  local isClaim = false
  self.includePublicPermission = true
  if structureName then
    local structureType = string.sub(structureName, 1, #structureName - 2)
    self.ScreenHeader:SetBgVisible(true)
    local isSkillStructure = KeyIsInsideTable(self.skillDisplayStructures, structureType)
    if isSkillStructure then
      self.structureType = structureType
      self:UpdateSkillInfo(structureType)
      if not self.categoricalProgressionHandler then
        local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
        self.categoricalProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, playerEntityId)
      end
    end
    local isWalletStructure = self.walletStructures[structureType]
    if isWalletStructure then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", self.UpdateCurrency)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.AzothAmount", function(self, currencyAmount)
        self.ScreenHeader:SetAzoth(currencyAmount)
      end)
    end
    if isWalletStructure and isSkillStructure then
      self.ScreenHeader:SetStyle(self.ScreenHeader.SCREEN_HEADER_STYLE_SKILL_AND_CURRENCY)
    elseif isWalletStructure then
      self.ScreenHeader:SetStyle(self.ScreenHeader.SCREEN_HEADER_STYLE_COIN_AND_AZOTH)
    elseif isSkillStructure then
      self.ScreenHeader:SetStyle(self.ScreenHeader.SCREEN_HEADER_STYLE_SKILL)
    end
    local isTradingPost = structureType == "TradingPost"
    local contractsEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_enableContracts")
    UiElementBus.Event.SetIsEnabled(self.OutpostDisplay, contractsEnabled and isTradingPost)
    if contractsEnabled and isTradingPost then
      UiTextBus.Event.SetTextWithFlags(self.OutpostNameText, self:GetCurrentOutpostName(), eUiTextSet_SetLocalized)
    end
    local isGuildOwned = false
    if ownershipEntityId:IsValid() then
      isGuildOwned = OwnershipRequestBus.Event.IsGuildOwned(ownershipEntityId)
    end
    local isPermissionsStructure = self.permissionsDisplayStructures[structureType] or isClaim
    if isPermissionsStructure and isGuildOwned then
      local permissionsList = GuildsComponentBus.Broadcast.GetListOfRanksForDropdown(self.includePublicPermission)
      self.numberOfRanks = #permissionsList
      local permissionListData = {}
      for i = 1, #permissionsList do
        table.insert(permissionListData, {
          text = permissionsList[i]
        })
      end
      local structureGuildId = OwnershipRequestBus.Event.GetGuildId(ownershipEntityId)
      local myGuildId = GuildsComponentBus.Broadcast.GetGuildId()
      local canChangeSecurityLevel = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Structure_Assign) and myGuildId == structureGuildId
      if 0 < #permissionsList then
        local currentPermission = {}
        currentPermission.itemIndex = self:ConvertSecurityLevelToIndex(OwnershipRequestBus.Event.GetGuildSecurityLevel(ownershipEntityId))
        if 0 < currentPermission.itemIndex and currentPermission.itemIndex <= #permissionsList then
          currentPermission.text = permissionsList[currentPermission.itemIndex]
        end
        self.PermissionsDropdown:SetListData(permissionListData)
        self.PermissionsDropdown:SetSelectedItemData(currentPermission)
        self.PermissionsDropdown:SetEnableDropdownUsage(canChangeSecurityLevel)
      end
      UiElementBus.Event.SetIsEnabled(self.PermissionsText, 0 < #permissionsList)
      UiElementBus.Event.SetIsEnabled(self.EditCustomNameButton, self.focusedEntityInfo.supportsCustomName and canChangeSecurityLevel)
    else
      UiElementBus.Event.SetIsEnabled(self.EditCustomNameButton, false)
      UiElementBus.Event.SetIsEnabled(self.PermissionsText, false)
    end
    return true
  end
  return false
end
function StationProperties:OnCategoricalProgressionRankChanged(masteryNameCrc, oldRank, newRank, oldPoints)
  self:UpdateSkillInfo(self.structureType)
end
function StationProperties:OnCategoricalProgressionPointsChanged(masteryNameCrc, oldRank, newRank, oldPoints)
  self:UpdateSkillInfo(self.structureType)
end
function StationProperties:UpdateSkillInfo(structureType)
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local currentRank = CategoricalProgressionRequestBus.Event.GetRank(playerEntityId, self.skillDisplayStructures[structureType].tableId)
  local currentProgression = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, self.skillDisplayStructures[structureType].tableId)
  local maxProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(playerEntityId, self.skillDisplayStructures[structureType].tableId, currentRank)
  local progressPercent = 0
  if 0 < maxProgression then
    progressPercent = currentProgression / maxProgression
  end
  self.ScreenHeader:SetSkill1(self.skillDisplayStructures[structureType].locName)
  self.ScreenHeader:SetSkill1Circle(currentRank, progressPercent)
  if self.secondarySkills[structureType] then
    local currentSecondaryRank = CategoricalProgressionRequestBus.Event.GetRank(playerEntityId, self.secondarySkills[structureType].tableId)
    local currentSecondaryProgression = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, self.secondarySkills[structureType].tableId)
    local maxSecondaryProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(playerEntityId, self.secondarySkills[structureType].tableId, currentSecondaryRank)
    local progressPercent = 0
    if 0 < maxSecondaryProgression then
      progressPercent = currentSecondaryProgression / maxSecondaryProgression
    end
    self.ScreenHeader:SetSkill2(self.secondarySkills[structureType].locName)
    self.ScreenHeader:SetSkill2Circle(currentSecondaryRank, progressPercent)
    self.ScreenHeader:SetSkill2Visible(true)
    if self.tertiarySkills[structureType] then
      local currentTertiaryRank = CategoricalProgressionRequestBus.Event.GetRank(playerEntityId, self.tertiarySkills[structureType].tableId)
      local currentTertiaryProgression = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, self.tertiarySkills[structureType].tableId)
      local maxTertiaryProgression = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(playerEntityId, self.tertiarySkills[structureType].tableId, currentTertiaryRank)
      local progressPercent = 0
      if 0 < maxTertiaryProgression then
        progressPercent = currentTertiaryProgression / maxTertiaryProgression
      end
      self.ScreenHeader:SetSkill3(self.tertiarySkills[structureType].locName)
      self.ScreenHeader:SetSkill3Circle(currentTertiaryRank, progressPercent)
      self.ScreenHeader:SetSkill3Visible(true)
    else
      self.ScreenHeader:SetSkill3Visible(false)
    end
  else
    self.ScreenHeader:SetSkill2Visible(false)
    self.ScreenHeader:SetSkill3Visible(false)
  end
end
function StationProperties:SetHeaderText(value)
  if value then
    local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_stationName", value)
    self.ScreenHeader:SetText(text, true)
  end
end
function StationProperties:SetHeaderTextBackToStationName()
  if self.displayName then
    local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_stationName", self.displayName)
    self.ScreenHeader:SetText(text, true)
  end
end
function StationProperties:ConvertIndexToSecurityLevel(index)
  local index = self.numberOfRanks - index
  if self.includePublicPermission == false then
    index = index + 1
  end
  return index
end
function StationProperties:ConvertSecurityLevelToIndex(securityLevel)
  local index = self.numberOfRanks - securityLevel
  if self.includePublicPermission == false then
    index = index + 1
  end
  return index
end
function StationProperties:OnPermissionChanged(dropdownItem, dropdownItemData)
  local securityLevel = self:ConvertIndexToSecurityLevel(dropdownItemData.itemIndex)
  if securityLevel < 0 then
    securityLevel = 0
  end
  LocalPlayerUIRequestsBus.Broadcast.SetSecurityLevel(securityLevel)
end
function StationProperties:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.ownershipNotificationsHandler then
    self:BusDisconnect(self.ownershipNotificationsHandler)
    self.ownershipNotificationsHandler = nil
  end
  if fromState == 2972535350 and toState == 3349343259 or toState == 1319313135 or toState == 3211015753 or toState == 3370453353 or toState == 640726528 or toState == 3349343259 and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop") or not self:Update() then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function StationProperties:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  if self.ownershipNotificationsHandler then
    self:BusDisconnect(self.ownershipNotificationsHandler)
    self.ownershipNotificationsHandler = nil
  end
  if self.ownershipNotificationsHandler then
    self:BusDisconnect(self.categoricalProgressionHandler)
    self.categoricalProgressionHandler = nil
  end
  self:SetNameCustomizationEnabled(false)
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function StationProperties:UpdateCurrency(data)
  self.currentWalletAmount = data
  self.ScreenHeader:SetCoin(self.currentWalletAmount)
end
function StationProperties:SetOutpostList()
  if not self.hasOutpostData then
    local outpostCapitals = MapComponentBus.Broadcast.GetOutposts()
    if not outpostCapitals or #outpostCapitals == 0 then
      return
    end
    self.hasOutpostData = true
    self.outpostList = {}
    for i = 1, #outpostCapitals do
      self.outpostList[outpostCapitals[i].id] = outpostCapitals[i].nameLocalizationKey
    end
    local settlementCapitals = MapComponentBus.Broadcast.GetSettlements()
    for i = 1, #settlementCapitals do
      self.outpostList[settlementCapitals[i].id] = settlementCapitals[i].nameLocalizationKey
    end
  end
end
function StationProperties:GetCurrentOutpostName()
  self:SetOutpostList()
  local outpostId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  local locKey = self.outpostList[outpostId]
  locKey = locKey or ""
  return locKey
end
function StationProperties:SetVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
end
function StationProperties:SetTransparent(isTransparent)
  if isTransparent then
    self.ScreenHeader:SetContentVisible(false)
  else
    self.ScreenHeader:SetContentVisible(true)
  end
end
function StationProperties:SetBackgroundTransparent(isTransparent)
  if isTransparent then
    self.ScreenHeader:SetBgVisible(false)
  else
    self.ScreenHeader:SetBgVisible(true)
  end
end
function StationProperties:EditCustomName()
  self:SetNameCustomizationEnabled(true)
  UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.CustomNameTextInput, false)
  UiTextInputBus.Event.BeginEdit(self.CustomNameTextInput)
  local stationText = self.ScreenHeader:GetText()
  self.currentStationName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(stationText)
  UiTextInputBus.Event.SetText(self.CustomNameTextInput, self.currentStationName)
end
function StationProperties:OnCustomNameStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
end
function StationProperties:OnCustomNameEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
end
function StationProperties:SubmitCustomName()
  local stationText = UiTextInputBus.Event.GetText(self.CustomNameTextInput)
  if stationText ~= self.currentStationName then
    if LocalPlayerUIRequestsBus.Broadcast.SetStructureName(stationText) then
      self.ScreenHeader:SetText(stationText, true)
    else
      UiTextInputBus.Event.SetText(self.CustomNameTextInput, self.currentStationName)
    end
  end
  self:SetNameCustomizationEnabled(false)
end
function StationProperties:SetNameCustomizationEnabled(isEnabled)
  UiElementBus.Event.SetIsEnabled(self.CustomNameContainer, isEnabled)
  UiElementBus.Event.SetIsEnabled(self.EditCustomNameButton, not isEnabled)
  self.ScreenHeader:SetTextVisible(not isEnabled)
end
function StationProperties:SetBackButtonCallback(callback, callbackTable)
  self.ScreenHeader:SetHintCallback(callback, callbackTable)
end
function StationProperties:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.StationPropertiesBus.Disconnect(self.entityId, self)
  self.categoricalProgressionHandler = nil
  self.ownershipNotificationsHandler = nil
end
return StationProperties
