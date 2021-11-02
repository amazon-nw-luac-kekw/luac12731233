local ArenaEnterMenu = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    TimerContainer = {
      default = EntityId()
    },
    TimerElement = {
      default = EntityId()
    },
    ResourceNameText = {
      default = EntityId()
    },
    ResourceQuantityText = {
      default = EntityId()
    },
    ResourceImage = {
      default = EntityId()
    },
    BuyButton = {
      default = EntityId()
    },
    DescText = {
      default = EntityId()
    },
    RewardsText = {
      default = EntityId()
    },
    ObjectiveText = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    }
  },
  requiredItemDescriptor = ItemDescriptor(),
  currentResourceAmount = 0,
  requiredResourceAmount = 0,
  iconPathRoot = "lyShineui/images/icons/items/resource/",
  backgroundXOffset = 300
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ArenaEnterMenu)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function ArenaEnterMenu:OnInit()
  BaseScreen.OnInit(self)
  self.requiredItemDescriptor.quantity = 1
  self.requiredItemDescriptor.slotIndex = -1
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    self.inventoryId = data
  end)
  self.BuyButton:SetCallback(self.BuyEntry, self)
  self.BuyButton:SetButtonStyle(self.BuyButton.BUTTON_STYLE_CTA)
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
end
function ArenaEnterMenu:OnShutdown()
end
function ArenaEnterMenu:SetRequiredItemId(itemId)
  self.requiredItemDescriptor.itemId = Math.CreateCrc32(itemId)
  self.requiredItemTdi = StaticItemDataManager:GetTooltipDisplayInfo(self.requiredItemDescriptor)
  local name = self.requiredItemTdi.displayName
  local iconPath = self.iconPathRoot .. self.requiredItemTdi.iconPath .. ".dds"
  UiTextBus.Event.SetTextWithFlags(self.Properties.ResourceNameText, name, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.ResourceImage, iconPath)
end
function ArenaEnterMenu:OnEncounterRewardsSynced(successRewardDataId)
  local rewardsText = ""
  if successRewardDataId and successRewardDataId ~= 0 then
    local successRewardData = GameEventRequestBus.Broadcast.GetGameSystemData(successRewardDataId)
    if 0 < successRewardData.territoryStanding then
      local territoryStanding = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_detailed_rewardtype_standing", tostring(successRewardData.territoryStanding))
      rewardsText = rewardsText .. territoryStanding .. "\n"
    end
    if 0 < tonumber(successRewardData.currencyRewardRange) then
      local currencyReward = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_arena_rewardtype_currency", GetLocalizedCurrency(successRewardData.currencyRewardRange))
      rewardsText = rewardsText .. currencyReward .. "\n"
    end
    if 0 < successRewardData.progressionReward then
      local progressionReward = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_rewardtype_experience", tostring(successRewardData.progressionReward))
      rewardsText = rewardsText .. progressionReward .. "\n"
    end
    if 0 < successRewardData.azothReward then
      local azothReward = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_arena_rewardtype_azoth", tostring(successRewardData.azothReward))
      rewardsText = rewardsText .. azothReward .. "\n"
    end
    local itemReward = successRewardData.itemReward
    if 0 < string.len(itemReward) then
      local itemRewardText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(StaticItemDataManager:GetItemName(itemReward))
      local itemRewardDisplayText = GetLocalizedReplacementText("@ui_arena_item_reward", {
        icon = "lyshineui/images/icons/items/resource/SprigganRewardContainer1.dds",
        itemname = itemRewardText
      })
      rewardsText = rewardsText .. itemRewardDisplayText .. "\n"
    end
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.RewardsText, rewardsText, eUiTextSet_SetLocalized)
end
function ArenaEnterMenu:OnTransitionIn(stateName, levelName)
  if self.containerEventHandler then
    self:BusDisconnect(self.containerEventHandler)
  end
  self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  local interactable = UiInteractorComponentRequestsBus.Event.GetInteractable(interactorEntity)
  self.arenaRoot = TransformBus.Event.GetRootId(interactable)
  self.encounterEventHandler = self:BusConnect(EncounterRewardsNotficationBus, self.arenaRoot)
  local cachedRewardsData = EncounterRewardsBus.Event.GetEncounterRewards(self.arenaRoot)
  self:OnEncounterRewardsSynced(cachedRewardsData)
  if self.arenaEventHandler then
    self:BusDisconnect(self.arenaEventHandler)
  end
  self.arenaEventHandler = self:BusConnect(ArenaEventBus, self.arenaRoot)
  self.isArenaAvailable = not ArenaRequestBus.Event.IsArenaActive(self.arenaRoot)
  self.isActivatingArena = false
  self.allMembersInProximity = ArenaRequestBus.Event.GetAllGroupMembersInProximity(self.arenaRoot)
  self.allMembersAlive = ArenaRequestBus.Event.GetAllGroupMembersAlive(self.arenaRoot)
  local requiredItemAmount = 1
  local titleText = "@ui_arena_title"
  local descText = "@ui_arena_description"
  local objectiveText = "@ui_arena_objective"
  local requiredItemId = "OilT1"
  local requiredItems = ArenaRequestBus.Event.GetArenaRequiredItems(self.arenaRoot)
  if 0 < #requiredItems then
    requiredItemId = requiredItems[1]:GetItemKey()
    requiredItemAmount = requiredItems[1].quantity
  end
  local territoryId = TerritoryComponentRequestBus.Event.GetTerritoryId(interactorEntity)
  if territoryId then
    local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryId)
    if territoryDefn then
      titleText = territoryDefn.nameLocalizationKey
    end
  end
  self:SetRequiredItemId(requiredItemId)
  local currentItemAmount = ContainerRequestBus.Event.GetMaxUniqueItemCount(self.inventoryId, self.requiredItemDescriptor, false)
  self:UpdateResourceQuantityText(currentItemAmount, requiredItemAmount)
  self:UpdateBuyButton()
  local arenaMonsterName = ArenaRequestBus.Event.GetArenaMonsterName(self.arenaRoot)
  if not arenaMonsterName or arenaMonsterName == "" then
    arenaMonsterName = "@spriggan_name"
  end
  titleText = GetLocalizedReplacementText(titleText, {monstername = arenaMonsterName})
  objectiveText = GetLocalizedReplacementText(objectiveText, {monstername = arenaMonsterName})
  self.ScreenHeader:SetText(titleText)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescText, descText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ObjectiveText, objectiveText, eUiTextSet_SetLocalized)
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_ArenaEnterMenu", 0.5)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 3
  self.targetDOFBlur = 0.75
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 1.2,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
end
function ArenaEnterMenu:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  if self.containerEventHandler then
    self:BusDisconnect(self.containerEventHandler)
    self.containerEventHandler = nil
  end
  if self.encounterEventHandler then
    self:BusDisconnect(self.encounterEventHandler)
    self.encounterEventHandler = nil
  end
  if self.arenaEventHandler then
    self:BusDisconnect(self.arenaEventHandler)
    self.arenaEventHandler = nil
  end
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  self:OnUnfocusResource()
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntity then
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_ArenaEnterMenu", 0.5)
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function ArenaEnterMenu:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function ArenaEnterMenu:OnEscapeKeyPressed()
  self:OnExit()
end
function ArenaEnterMenu:OnContainerSlotChanged(slotNum, newItemDescriptor, oldItemDescriptor)
  if newItemDescriptor.itemId == self.requiredItemDescriptor.itemId or oldItemDescriptor.itemId == self.requiredItemDescriptor.itemId then
    local currentItemAmount = ContainerRequestBus.Event.GetMaxUniqueItemCount(self.inventoryId, self.requiredItemDescriptor, false)
    self:UpdateResourceQuantityText(currentItemAmount)
  end
end
function ArenaEnterMenu:OnArenaActivateResult(success)
  LyShineManagerBus.Broadcast.ExitState(3664731564)
  if not success then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_arena_activate_failure"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self.isActivatingArena = false
end
function ArenaEnterMenu:OnArenaStateChanged(isActive)
  self.isArenaAvailable = not isActive
  self:UpdateBuyButton()
end
function ArenaEnterMenu:OnArenaEndTimeChanged(secondsRemaining)
  self.TimerElement:SetTimeSeconds(secondsRemaining, true)
end
function ArenaEnterMenu:OnGroupMembersProximityChanged(allMembersInProximity)
  self.allMembersInProximity = allMembersInProximity
  self:UpdateBuyButton()
end
function ArenaEnterMenu:OnGroupMembersAliveChanged(allMembersAlive)
  self.allMembersAlive = allMembersAlive
  self:UpdateBuyButton()
end
function ArenaEnterMenu:OnExit(entityId, actionName)
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function ArenaEnterMenu:UpdateResourceQuantityText(currentAmount, requiredAmount)
  self.currentResourceAmount = currentAmount or self.currentResourceAmount
  self.requiredResourceAmount = requiredAmount or self.requiredResourceAmount
  self:UpdateQuantityText(self.ResourceQuantityText, self.currentResourceAmount, self.requiredResourceAmount)
end
function ArenaEnterMenu:UpdateQuantityText(quantityText, currentAmount, requiredAmount)
  local insufficientQuantityColor = self.UIStyle.COLOR_RED_LIGHT
  local sufficientQuantityColor = self.UIStyle.COLOR_WHITE
  local fontColor = insufficientQuantityColor
  if requiredAmount <= currentAmount then
    fontColor = sufficientQuantityColor
  end
  currentAmount = GetLocalizedNumber(currentAmount)
  requiredAmount = GetLocalizedNumber(requiredAmount)
  UiTextBus.Event.SetText(quantityText, string.format("<font color=\"#%2x%2x%2x\">%s</font> / %s", fontColor.r * 255, fontColor.g * 255, fontColor.b * 255, currentAmount, requiredAmount))
  self:UpdateBuyButton()
end
function ArenaEnterMenu:UpdateBuyButton()
  local arenaAvailable = self.isArenaAvailable
  if arenaAvailable then
    local hasEnoughResources = self.currentResourceAmount >= self.requiredResourceAmount
    local buttonText = "@ui_activate_arena"
    if not hasEnoughResources then
      buttonText = "@ui_not_enough_resources"
    elseif not self.allMembersInProximity then
      buttonText = "@ui_arena_group_proximity"
    elseif not self.allMembersAlive then
      buttonText = "@ui_arena_group_dead"
    elseif self.isActivatingArena then
      buttonText = "@ui_arena_activating"
    end
    self.BuyButton:SetText(buttonText)
    local buttonEnabled = hasEnoughResources and not self.isActivatingArena and self.allMembersInProximity and self.allMembersAlive
    self.BuyButton:SetEnabled(buttonEnabled)
  else
    local unavailableTime = ArenaRequestBus.Event.GetArenaSecondsRemaining(self.arenaRoot)
    self.TimerElement:SetTimeSeconds(unavailableTime, true)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.TimerContainer, not arenaAvailable)
  UiElementBus.Event.SetIsEnabled(self.Properties.BuyButton, arenaAvailable)
end
function ArenaEnterMenu:OnFocusResource()
  DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(self.requiredItemTdi, nil)
end
function ArenaEnterMenu:OnUnfocusResource()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
function ArenaEnterMenu:BuyEntry()
  self.isActivatingArena = true
  LocalPlayerUIRequestsBus.Broadcast.UseArenaItem()
  self:UpdateBuyButton()
end
return ArenaEnterMenu
