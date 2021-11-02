local LootTicker = {
  Properties = {
    ItemImageDirectory = {
      default = "lyshineui/images/items"
    },
    VerticalLine = {
      default = EntityId()
    },
    HorizontalLine1 = {
      default = EntityId()
    },
    TradeSkillContainer = {
      default = EntityId()
    },
    TradeSkillRadial = {
      default = EntityId()
    },
    TradeSkillCurrentRank = {
      default = EntityId()
    },
    TradeSkillText = {
      default = EntityId()
    },
    TradeSkillRingContainer = {
      default = EntityId()
    },
    TradeSkillFlash = {
      default = EntityId()
    },
    NumberText = {
      default = EntityId()
    },
    Pulse1 = {
      default = EntityId()
    },
    Pulse2 = {
      default = EntityId()
    },
    BgContainer = {
      default = EntityId()
    },
    ProgressionTickerItemContainer = {
      default = EntityId()
    },
    ProgressionTickerItem = {
      default = EntityId()
    },
    ProgressionTickerItem2 = {
      default = EntityId()
    },
    ProgressionTickerItem3 = {
      default = EntityId()
    },
    ProgressionTickerItem4 = {
      default = EntityId()
    },
    ProgressionTickerItem5 = {
      default = EntityId()
    },
    ProgressionTickerItem6 = {
      default = EntityId()
    },
    ProgressionTickerItem7 = {
      default = EntityId()
    },
    LootTickerBg = {
      default = EntityId()
    }
  },
  TIME_TO_SHOW = 3,
  remainingTime = 0,
  numShowing = 0,
  inventoryStateName = 2972535350,
  containerStateName = 3349343259,
  p2pTradeStateName = 2552344588,
  conversationStateName = 1101180544,
  isInInventoryState = false,
  isAligned = false,
  childCount = 0,
  longTextWidth = 425,
  isFtue = false,
  screenStatesToDisable = {
    [849925872] = true,
    [921202721] = true,
    [1101180544] = true
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(LootTicker)
local inventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local TradeSkillsCommon = RequireScript("LyShineUI._Common.TradeSkillsCommon")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function LootTicker:OnInit()
  BaseScreen.OnInit(self)
  self.progressionEventQueue = {}
  self.lootQueue = {}
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    UiElementBus.Event.SetIsEnabled(self.ProgressionTickerItemContainer, false)
  end
  self:BusConnect(LyShineScriptBindNotificationBus, self.canvasId)
  DynamicBus.QuickslotNotifications.Connect(self.entityId, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionId)
    if factionId and factionId ~= eFactionType_None then
      self.factionId = factionId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryId)
    if inventoryId then
      self.inventoryId = inventoryId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if self.playerEntityId then
      local availablePoints = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, 928006727)
      local maxAzothPoints = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, 928006727, 0)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.AzothMax", maxAzothPoints)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.AzothAmount", availablePoints)
      local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
      if playerFaction and playerFaction ~= eFactionType_None and playerFaction ~= eFactionType_Any then
        local reputationId = FactionRequestBus.Event.GetFactionReputationProgressionIdFromType(self.playerEntityId, playerFaction)
        local reputationAmount = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, reputationId)
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.FactionReputationAmount", reputationAmount)
        local tokensId = FactionRequestBus.Event.GetFactionTokensProgressionIdFromType(self.playerEntityId, playerFaction)
        local tokensAmount = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, tokensId)
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.FactionTokensAmount", tokensAmount)
      else
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.FactionReputationAmount", 0)
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.FactionTokensAmount", 0)
      end
    end
  end)
  self.walletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-player")
  self.lootTickerDisplayItems = {}
  local childElements = UiElementBus.Event.GetChildren(self.entityId)
  self.childCount = #childElements
  for i = 1, self.childCount do
    local lootTickerItem = self.registrar:GetEntityTable(childElements[i])
    table.insert(self.lootTickerDisplayItems, lootTickerItem)
  end
  self.ScriptedEntityTweener:Set(self.Properties.LootTickerBg, {opacity = 0})
  self.showingLootItems = 0
  self.displayDataCb = {
    func = self.OnItemHidden,
    caller = self
  }
  self.queuedProgressionTick = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.rootEntityId = rootEntityId
      if self.categoricalProgressionHandler then
        self:BusDisconnect(self.categoricalProgressionHandler)
      end
      self.categoricalProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, rootEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", function(self, objectiveEntityId)
    if objectiveEntityId == nil then
      return
    end
    if self.objectivesComponentBusHandler then
      self:BusDisconnect(self.objectivesComponentBusHandler)
    end
    self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, objectiveEntityId)
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.TradeSkillContainer, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableNewProgressionTicker", function(self, enableNewProgressionTicker)
    if self.isFtue then
      return
    end
    self.enableNewProgressionTicker = enableNewProgressionTicker
    if enableNewProgressionTicker then
      if not self.damageNumberNotificationsBus then
        self.damageNumberNotificationsBus = self:BusConnect(DamageNumbersNotificationBus, self.entityId)
      end
      if not self.gameEventUiNotificationBusHandler then
        self.gameEventUiNotificationBusHandler = self:BusConnect(GameEventUiNotificationBus)
      end
      self.progressionTickerItems = {
        [eXpEventType_Azoth] = {
          entity = self.ProgressionTickerItem5,
          delay = 0.3,
          fadeoutDelay = 5,
          priority = 1
        },
        [eXpEventType_Currency] = {
          entity = self.ProgressionTickerItem4,
          delay = 0.15,
          fadeoutDelay = 2,
          priority = 2
        },
        [eXpEventType_PlayerXp] = {
          entity = self.ProgressionTickerItem,
          delay = 0.1,
          fadeoutDelay = 1,
          priority = 3
        },
        [eXpEventType_Tradeskill] = {
          entity = self.ProgressionTickerItem2,
          delay = 0.2,
          fadeoutDelay = 3,
          priority = 4
        },
        [eXpEventType_Standing] = {
          entity = self.ProgressionTickerItem3,
          delay = 0.25,
          fadeoutDelay = 4,
          priority = 5
        },
        [eXpEventType_Reputation] = {
          entity = self.ProgressionTickerItem6,
          delay = 0.35,
          fadeoutDelay = 6,
          priority = 6
        },
        [eXpEventType_Tokens] = {
          entity = self.ProgressionTickerItem7,
          delay = 0.4,
          fadeoutDelay = 7,
          priority = 7
        }
      }
      self.offsetAmount = 50
    else
      if self.damageNumberNotificationsBus then
        self:BusDisconnect(self.damageNumberNotificationsBus)
        self.damageNumberNotificationsBus = nil
      end
      if self.gameEventUiNotificationBusHandler then
        self:BusDisconnect(self.gameEventUiNotificationBusHandler)
        self.gameEventUiNotificationBusHandler = nil
      end
    end
  end)
  self:OnWeaponSlotsVisible(false)
  self.shouldTick = true
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", function(self, currencyAmount)
    if not self.currencyAmount then
      self.currencyAmount = currencyAmount
      return
    end
    if currencyAmount >= self.walletCap then
      currencyAmount = self.walletCap
    end
    local delta = currencyAmount - self.currencyAmount
    if 0 < delta then
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Currency, delta)
    end
    self.currencyAmount = currencyAmount
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Currency.LostAmount", function(self, lostAmount)
    if lostAmount then
      if self.currencyAmount < self.walletCap then
        local delta = self.walletCap + lostAmount
        self:OnLocalPlayerNumberDisplayed(eXpEventType_Currency, delta)
        self.currencyAmount = self.walletCap
      else
        self:OnLocalPlayerNumberDisplayed(eXpEventType_Currency, -lostAmount)
      end
    end
  end)
end
function LootTicker:OnShutdown()
  BaseScreen.OnShutdown(self)
  self.categoricalProgressionHandler = nil
  TimingUtils:StopDelay(self)
  DynamicBus.QuickslotNotifications.Disconnect(self.entityId, self)
end
function LootTicker:OnScreenStateChanged(stateName, isTransitionIn)
  if stateName == self.inventoryStateName or stateName == self.containerStateName or stateName == self.p2pTradeStateName or stateName == self.conversationStateName then
    self.isInInventoryState = isTransitionIn
  end
  if self.isInInventoryState then
    for displayIndex, lootItem in ipairs(self.lootTickerDisplayItems) do
      if lootItem.isShowing then
        lootItem:Hide()
      end
    end
  end
end
function LootTicker:OnLootReceived(itemSlot, quantity)
  if self.isInInventoryState then
    return
  end
  local staticItemData = StaticItemDataManager:GetItem(itemSlot:GetItemId())
  if staticItemData.hideInLootTicker then
    return
  end
  local weight = 0
  local size = 0
  if itemSlot:GetActionCausingSync() == eItemContainerSync_Fishing then
    weight = FishingRequestsBus.Event.GetFishWeight(self.rootEntityId)
    size = FishingRequestsBus.Event.GetFishLength(self.rootEntityId)
  end
  table.insert(self.lootQueue, {
    quantity = quantity,
    itemDescriptor = itemSlot:GetItemDescriptor(),
    weight = weight,
    size = size
  })
  self:SetTickConnection(self.shouldTick)
end
function LootTicker:OnItemHidden()
  local prevShowing = self.showingLootItems
  self.showingLootItems = math.max(self.showingLootItems - 1, 0)
  if self.showingLootItems == 0 and prevShowing ~= 0 then
    self.ScriptedEntityTweener:Play(self.Properties.LootTickerBg, 0.2, {opacity = 0})
    self.HorizontalLine1:SetVisible(false, 0.3)
    self.VerticalLine:SetVisible(false, 0.3)
    self.ScriptedEntityTweener:Play(self.Properties.LootTickerBg, 0.2, {
      scaleY = 1,
      onComplete = function()
        DynamicBus.LootTickerNotifications.Broadcast.OnLootTickerVisibilityChange(false)
      end
    })
  end
end
function LootTicker:OnTick(deltaTime, timePoint)
  DynamicBus.UITickBus.Disconnect(self.entityId, self)
  self.tickBusHandler = nil
  table.sort(self.lootQueue, function(a, b)
    return a.itemDescriptor:GetRarityLevel() > b.itemDescriptor:GetRarityLevel()
  end)
  local overflowIndex = 1
  for index, lootData in ipairs(self.lootQueue) do
    local itemToInit
    local isTopLootItem = false
    local descriptor = lootData.itemDescriptor
    for displayIndex, lootItem in ipairs(self.lootTickerDisplayItems) do
      if not lootItem.isShowing then
        itemToInit = lootItem
        isTopLootItem = displayIndex == 1
        break
      else
        lootItem:ResetDelay()
        lootItem:HideTotalIfDescMatch(descriptor)
      end
    end
    if not itemToInit then
      if overflowIndex > #self.lootTickerDisplayItems then
        break
      end
      itemToInit = self.lootTickerDisplayItems[overflowIndex]
      overflowIndex = overflowIndex + 1
    end
    local itemData = ItemDataManagerBus.Broadcast.GetItemData(descriptor.itemId)
    local itemType = itemData.itemType
    local hideRarityEffect = itemType == "Resource" or itemType == "HousingItem" or itemType == "Lore" or itemType == "Dye"
    local playRarityEffect = isTopLootItem and index == 1 and descriptor:UsesRarity() and descriptor:GetRarityLevel() > 0 and not hideRarityEffect
    local itemCount = inventoryCommon:GetInventoryItemCount(descriptor)
    itemToInit:SetDisplayData(descriptor, lootData.quantity, itemCount, self.displayDataCb, playRarityEffect, index, lootData)
    if self.showingLootItems == 0 then
      self.ScriptedEntityTweener:Play(self.Properties.LootTickerBg, 0.5, {opacity = 1, delay = 0.2})
      self.HorizontalLine1:SetVisible(true, 1)
      self.VerticalLine:SetVisible(true, 1)
      DynamicBus.LootTickerNotifications.Broadcast.OnLootTickerVisibilityChange(true)
    end
    self.showingLootItems = self.showingLootItems + 1
  end
  ClearTable(self.lootQueue)
  if self.enableNewProgressionTicker then
    table.sort(self.queuedProgressionTick, function(a, b)
      local aPriority = self.progressionTickerItems[a.eventType].priority or 0
      local bPriority = self.progressionTickerItems[b.eventType].priority or 0
      return aPriority < bPriority
    end)
    do
      local numEnabled = 0
      for _, tickerData in pairs(self.progressionTickerItems) do
        if tickerData.entity:IsEnabled() or tickerData.delayTimingHandle then
          numEnabled = numEnabled + 1
        end
      end
      local numTradeskillItems = 0
      local progressionToRequeue
      local additionalOffset = numEnabled * self.offsetAmount
      local showedProgressionItems = false
      for _, progressionItem in ipairs(self.queuedProgressionTick) do
        local eventType = progressionItem.eventType
        local amount = progressionItem.amount
        local masteryNameCrc = progressionItem.masteryNameCrc
        local processEvent = true
        if eventType == eXpEventType_Tradeskill then
          numTradeskillItems = numTradeskillItems + 1
          if 1 < numTradeskillItems then
            progressionToRequeue = progressionItem
            processEvent = false
          end
        end
        if processEvent then
          do
            local tickerData = self.progressionTickerItems[eventType]
            if tickerData then
              showedProgressionItems = true
              do
                local timeToDelay = tickerData.delay
                local fadeoutDelay = tickerData.fadeoutDelay
                if tickerData.delayTimingHandle then
                  TimingUtils:StopDelay(tickerData.delayTimingHandle)
                end
                local updateValue = tickerData.entity:IsEnabled() and (eventType ~= eXpEventType_Tradeskill or tickerData.entity.lastMasteryNameCrc == masteryNameCrc)
                if updateValue then
                  tickerData.entity:UpdateValue(eventType, amount, masteryNameCrc, true)
                  tickerData.entity:QueueFadeOut(fadeoutDelay)
                else
                  do
                    local offsetToUse = additionalOffset
                    tickerData.delayTimingHandle = TimingUtils:Delay(timeToDelay, self, function()
                      local updateValue = tickerData.entity:IsEnabled() and (eventType ~= eXpEventType_Tradeskill or tickerData.entity.lastMasteryNameCrc == masteryNameCrc)
                      if updateValue then
                        tickerData.entity:UpdateValue(eventType, amount, masteryNameCrc, true)
                        tickerData.entity:QueueFadeOut(fadeoutDelay)
                      else
                        tickerData.entity:OnLocalPlayerNumberDisplayed(eventType, amount, masteryNameCrc, offsetToUse)
                      end
                      tickerData.delayTimingHandle = nil
                    end)
                    additionalOffset = additionalOffset + self.offsetAmount
                  end
                end
              end
            end
          end
        end
      end
      if 0 < #self.queuedProgressionTick then
        self.numVisible = #self.queuedProgressionTick
      end
      ClearTable(self.queuedProgressionTick)
      if progressionToRequeue then
        TimingUtils:Delay(2.5, self, function()
          table.insert(self.queuedProgressionTick, progressionToRequeue)
          self:SetTickConnection(self.shouldTick)
        end)
      end
      if not showedProgressionItems then
        for _, tickerItemData in pairs(self.progressionTickerItems) do
          if tickerItemData.entity:IsEnabled() then
            showedProgressionItems = true
            break
          end
        end
      end
      local bothLootAndProgressionShowing = showedProgressionItems and 0 < self.showingLootItems
      local yOffset
      local tradeskillOffset = self.progressionEventActive and 0 or 70
      if bothLootAndProgressionShowing then
        yOffset = -144 - self.numVisible * 50 + tradeskillOffset
      else
        yOffset = -56
        local viewportSize = LyShineScriptBindRequestBus.Broadcast.GetViewportSize()
        local ratio = viewportSize.y / viewportSize.x
        if 0.75 <= ratio then
          yOffset = yOffset - 105
        elseif 0.6 <= ratio then
          yOffset = yOffset - 36
        end
      end
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ProgressionTickerItemContainer, yOffset)
    end
  end
end
function LootTicker:OnCategoricalProgressionRankChanged(masteryNameCrc, oldRank, newRank, oldPoints)
  if LoadScreenBus.Broadcast.IsLoadingScreenShown() then
    return
  end
  if not self.enableNewProgressionTicker then
    return
  end
  if not TradeSkillsCommon:IsGatheringSkill(masteryNameCrc) then
    local progressionData = CategoricalProgressionRequestBus.Event.GetCategoricalProgressionData(self.playerEntityId, masteryNameCrc)
    if progressionData.rankTableId == "WeaponMastery" then
      local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, masteryNameCrc, oldRank)
      local prevRankGain = requiredProgress - oldPoints
      local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, masteryNameCrc)
      local totalGain = prevRankGain + currentProgress
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Tradeskill, totalGain, masteryNameCrc)
    end
  else
    local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(masteryNameCrc)
    if tradeSkillData then
      local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, masteryNameCrc, oldRank)
      local amount = requiredProgress - oldPoints
      local localizedText = GetLocalizedReplacementText("@ui_glory_update_floating_tradeskill", {
        masteryName = tradeSkillData.locName
      })
      local percent = oldPoints / requiredProgress
      self:QueueProgressionEvent(localizedText, oldRank, tradeSkillData.requireIcon, percent, 1, false, amount)
      for i = oldRank + 1, newRank do
        local currentProgress
        if newRank > i then
          currentProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, masteryNameCrc, i)
        else
          currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, masteryNameCrc)
        end
        local amount = currentProgress
        localizedText = GetLocalizedReplacementText("@ui_glory_update_floating_tradeskill", {
          masteryName = tradeSkillData.locName
        })
        requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, masteryNameCrc, i)
        percent = currentProgress / requiredProgress
        self:QueueProgressionEvent(localizedText, i, tradeSkillData.requireIcon, 0, percent, i == newRank, amount)
      end
    end
  end
end
function LootTicker:OnCategoricalProgressionPointsChanged(masteryNameCrc, oldPoints, newPoints)
  if masteryNameCrc == 928006727 then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.AzothAmount", newPoints)
    local pointsDelta = newPoints - oldPoints
    if 0 < pointsDelta then
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Azoth, pointsDelta, nil)
    end
    return
  end
  local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  if playerFaction and playerFaction ~= eFactionType_None and playerFaction ~= eFactionType_Any then
    local reputationId = FactionRequestBus.Event.GetFactionReputationProgressionIdFromType(self.playerEntityId, playerFaction)
    if masteryNameCrc == reputationId then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.FactionReputationAmount", newPoints)
      local pointsDelta = newPoints - oldPoints
      if 0 < pointsDelta then
        self:OnLocalPlayerNumberDisplayed(eXpEventType_Reputation, pointsDelta, nil)
      end
      return
    end
    local tokensId = FactionRequestBus.Event.GetFactionTokensProgressionIdFromType(self.playerEntityId, playerFaction)
    if masteryNameCrc == tokensId then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.FactionTokensAmount", newPoints)
      local pointsDelta = newPoints - oldPoints
      if 0 < pointsDelta then
        self:OnLocalPlayerNumberDisplayed(eXpEventType_Tokens, pointsDelta, nil)
      end
      return
    end
  end
  if not self.enableNewProgressionTicker then
    return
  end
  if not TradeSkillsCommon:IsGatheringSkill(masteryNameCrc) then
    local progressionData = CategoricalProgressionRequestBus.Event.GetCategoricalProgressionData(self.playerEntityId, masteryNameCrc)
    if progressionData.rankTableId == "WeaponMastery" then
      local currentRank = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, masteryNameCrc)
      if progressionData.maxRank ~= currentRank then
        local pointsDelta = newPoints - oldPoints
        if 0 < pointsDelta then
          self:OnLocalPlayerNumberDisplayed(eXpEventType_Tradeskill, pointsDelta, masteryNameCrc)
        end
      end
    end
  else
    local tradeSkillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(masteryNameCrc)
    if tradeSkillData then
      local amount = newPoints - oldPoints
      local localizedText = GetLocalizedReplacementText("@ui_glory_update_floating_tradeskill", {
        masteryName = tradeSkillData.locName
      })
      local currentLevel = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, masteryNameCrc)
      local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, masteryNameCrc, currentLevel)
      local oldPercent = oldPoints / requiredProgress
      local currentPercent = newPoints / requiredProgress
      self:QueueProgressionEvent(localizedText, currentLevel, tradeSkillData.requireIcon, oldPercent, currentPercent, true, amount)
    end
  end
end
function LootTicker:QueueProgressionEvent(masteryText, level, icon, oldPercent, newPercent, dequeueOnFadeOut, amount)
  if self.progressionEventActive or #self.progressionEventQueue > 0 then
    for _, queueData in ipairs(self.progressionEventQueue) do
      if queueData.level == level and queueData.icon == icon and queueData.newPercent == newPercent then
        return
      end
    end
    if UiTextBus.Event.GetText(self.Properties.TradeSkillText) == masteryText then
      if #self.progressionEventQueue == 0 and tostring(level) == UiTextBus.Event.GetText(self.Properties.TradeSkillCurrentRank) then
        self.progressionAmount = 0
        self:DisplayProgression(masteryText, icon, level, oldPercent, newPercent, dequeueOnFadeOut, amount)
        return
      elseif tostring(level) ~= UiTextBus.Event.GetText(self.Properties.TradeSkillCurrentRank) and #self.progressionEventQueue == 0 then
        self.progressionAmount = self.progressionAmount + amount
        amount = self.progressionAmount
        local amountText = ""
        if amount then
          amountText = "+ " .. self.progressionAmount
          UiTextBus.Event.SetText(self.Properties.NumberText, amountText)
        end
      end
    end
    table.insert(self.progressionEventQueue, {
      masteryText = masteryText,
      level = level,
      icon = icon,
      oldPercent = oldPercent,
      newPercent = newPercent,
      dequeueOnFadeOut = dequeueOnFadeOut,
      amount = amount
    })
  else
    self.progressionAmount = 0
    self:DisplayProgression(masteryText, icon, level, oldPercent, newPercent, dequeueOnFadeOut, amount)
  end
end
function LootTicker:DequeueProgressionEvent()
  local numInQueue = #self.progressionEventQueue
  if 0 < numInQueue then
    local topOfQueue = self.progressionEventQueue[1]
    table.remove(self.progressionEventQueue, 1)
    local amountToRemove = 0
    local leveledUp = not topOfQueue.dequeueOnFadeOut
    local pastLevelUp = false
    for _, queueData in ipairs(self.progressionEventQueue) do
      if queueData.masteryText ~= topOfQueue.masteryText then
        break
      end
      if not queueData.dequeueOnFadeOut then
        topOfQueue.dequeueOnFadeOut = queueData.dequeueOnFadeOut
        leveledUp = true
        topOfQueue.amount = queueData.amount
        topOfQueue.newPercent = queueData.newPercent
        amountToRemove = amountToRemove + 1
      elseif not leveledUp then
        topOfQueue.amount = queueData.amount
        if not pastLevelUp then
          amountToRemove = amountToRemove + 1
          topOfQueue.newPercent = queueData.newPercent
        end
      else
        topOfQueue.amount = topOfQueue.amount + queueData.amount
        queueData.amount = topOfQueue.amount
        leveledUp = false
        pastLevelUp = true
      end
    end
    for i = 1, amountToRemove do
      table.remove(self.progressionEventQueue, 1)
    end
    self.progressionAmount = 0
    self:DisplayProgression(topOfQueue.masteryText, topOfQueue.icon, topOfQueue.level, topOfQueue.oldPercent, topOfQueue.newPercent, topOfQueue.dequeueOnFadeOut, topOfQueue.amount)
  end
end
function LootTicker:DisplayProgression(localizedText, icon, currentLevel, startPercent, endPercent, dequeueOnFadeOut, amount)
  self.ScriptedEntityTweener:Stop(self.Properties.TradeSkillRadial)
  self.ScriptedEntityTweener:Stop(self.Properties.TradeSkillContainer)
  for displayIndex, lootItem in ipairs(self.lootTickerDisplayItems) do
    if lootItem.isShowing then
      lootItem:ResetDelay()
    end
  end
  self.progressionAmount = self.progressionAmount + amount
  local amountText = ""
  if amount then
    amountText = "+ " .. self.progressionAmount
    UiTextBus.Event.SetText(self.Properties.NumberText, amountText)
  end
  UiTextBus.Event.SetText(self.Properties.TradeSkillText, localizedText)
  UiTextBus.Event.SetText(self.Properties.TradeSkillCurrentRank, tostring(currentLevel))
  local numberTextOffset = 10
  self.ScriptedEntityTweener:Play(self.Properties.TradeSkillRadial, 1, {imgFill = startPercent}, {
    imgFill = endPercent,
    onComplete = function()
      if 1 <= endPercent then
        numberTextOffset = 0
        self.ScriptedEntityTweener:Play(self.Properties.Pulse1, 1, {
          scaleX = 0,
          scaleY = 0,
          opacity = 1
        }, {
          scaleX = 1.5,
          scaleY = 1.5,
          opacity = 0
        })
        self.ScriptedEntityTweener:Play(self.Properties.Pulse2, 1, {
          scaleX = 0,
          scaleY = 0,
          opacity = 1
        }, {
          scaleX = 1.5,
          scaleY = 1.5,
          opacity = 0,
          delay = 0.3
        })
        self.ScriptedEntityTweener:Play(self.Properties.TradeSkillRingContainer, 0.1, {scaleX = 0.4, scaleY = 0.4}, {scaleX = 0.55, scaleY = 0.55})
        self.ScriptedEntityTweener:Play(self.Properties.TradeSkillRingContainer, 0.6, {scaleX = 0.55, scaleY = 0.55}, {
          scaleX = 0.4,
          scaleY = 0.4,
          delay = 0.1,
          ease = "QuadOut"
        })
        self.ScriptedEntityTweener:Play(self.Properties.TradeSkillFlash, 0.1, {opacity = 1})
        self.ScriptedEntityTweener:Play(self.Properties.TradeSkillFlash, 0.3, {opacity = 0, delay = 0.1})
        self.audioHelper:PlaySound(self.audioHelper.Tradeskill_LevelUp)
        if not dequeueOnFadeOut then
          self:DequeueProgressionEvent()
        end
      else
        numberTextOffset = 10
      end
    end
  })
  self.progressionEventActive = true
  UiElementBus.Event.SetIsEnabled(self.Properties.TradeSkillContainer, true)
  self.ScriptedEntityTweener:Play(self.Properties.TradeSkillContainer, 0.1, {opacity = 1})
  self.ScriptedEntityTweener:Play(self.Properties.NumberText, 0.25, {
    opacity = 0,
    x = 106 - numberTextOffset
  }, {
    opacity = 1,
    x = 106,
    ease = "QuadOut",
    delay = 0.05
  })
  self.ScriptedEntityTweener:Play(self.Properties.TradeSkillContainer, 0.25, {
    opacity = 0,
    delay = 4,
    onComplete = function()
      self.progressionEventActive = false
      UiElementBus.Event.SetIsEnabled(self.Properties.TradeSkillContainer, false)
      if dequeueOnFadeOut then
        self:DequeueProgressionEvent()
      end
    end
  })
end
function LootTicker:OnLocalPlayerNumberDisplayed(eventType, amount, masteryNameCrc)
  if self.isInInventoryState then
    return
  end
  for _, progressionData in ipairs(self.queuedProgressionTick) do
    if progressionData.eventType == eventType and progressionData.masteryNameCrc == masteryNameCrc then
      progressionData.amount = progressionData.amount + amount
      return
    end
  end
  table.insert(self.queuedProgressionTick, {
    eventType = eventType,
    amount = amount,
    masteryNameCrc = masteryNameCrc
  })
  self:SetTickConnection(self.shouldTick)
end
function LootTicker:OnTypedUiGameEvent(gameEventType, progressionReward, currencyReward, itemReward, categoricalProgressionId, categoricalProgressionReward, territoryStandingReward, factionRepReward, factionTokensReward, azothReward)
  if gameEventType == eGameEventType_Darkness or gameEventType == eGameEventType_Arena or gameEventType == eGameEventType_PvPKill then
    local nilCrc = 0
    if categoricalProgressionReward and 0 < categoricalProgressionReward then
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Tradeskill, categoricalProgressionReward, categoricalProgressionId)
    end
    if self.factionId and factionRepReward and 0 < factionRepReward then
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Reputation, factionRepReward, self.factionId)
    end
    if self.factionId and factionTokensReward and 0 < factionTokensReward then
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Tokens, factionTokensReward, self.factionId)
    end
    if territoryStandingReward and 0 < territoryStandingReward then
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Standing, territoryStandingReward, nilCrc)
    end
  end
end
function LootTicker:OnObjectiveCompleted(objectiveId, objectiveCrcId, objCreation)
  local rewards = {}
  if objectiveCrcId then
    rewards = ObjectiveDataHelper:GetRewardDataFromCrc(objectiveCrcId, objCreation.missionId)
  elseif objectiveId then
    rewards = ObjectiveDataHelper:GetRewardData(objectiveId)
  else
    Debug.Log("LootTicker:OnObjectiveCompleted called without a valid objectiveId or objectiveCrcId")
    return
  end
  local nilCrc = 0
  for i = 1, #rewards do
    local rewardData = rewards[i]
    if rewardData.type == ObjectiveDataHelper.REWARD_TYPES.CATEGORICAL then
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Tradeskill, rewardData.value, rewardData.categoricalProgressionId)
    elseif rewardData.type == ObjectiveDataHelper.REWARD_TYPES.FACTION_REPUTATION then
      if self.factionId then
        self:OnLocalPlayerNumberDisplayed(eXpEventType_Reputation, rewardData.value, nilCrc)
      end
    elseif rewardData.type == ObjectiveDataHelper.REWARD_TYPES.FACTION_TOKENS then
      if self.factionId then
        self:OnLocalPlayerNumberDisplayed(eXpEventType_Tokens, rewardData.value, nilCrc)
      end
    elseif rewardData.type == ObjectiveDataHelper.REWARD_TYPES.TERRITORY_STANDING then
      self:OnLocalPlayerNumberDisplayed(eXpEventType_Standing, rewardData.value, nilCrc)
    end
  end
end
function LootTicker:OnWeaponSlotsVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.BgContainer, 0.25, {x = -46, ease = "QuadOut"})
    self.HorizontalLine1:SetLength(408)
  else
    self.ScriptedEntityTweener:Play(self.Properties.BgContainer, 0.25, {x = 180, ease = "QuadOut"})
    self.HorizontalLine1:SetLength(588)
  end
  for displayIndex, lootItem in ipairs(self.lootTickerDisplayItems) do
    lootItem:SetTextWidth(not isVisible and self.longTextWidth or nil)
  end
end
function LootTicker:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function LootTicker:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.shouldTick = true
  if self.shouldTick then
    self:SetTickConnection(self.shouldTick)
  end
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
end
function LootTicker:SetTickConnection(isEnabled)
  if isEnabled then
    if (#self.lootQueue > 0 or 0 < #self.queuedProgressionTick) and not self.tickBusHandler then
      self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
    end
  elseif self.tickBusHandler then
    self.tickBusHandler = DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
end
return LootTicker
