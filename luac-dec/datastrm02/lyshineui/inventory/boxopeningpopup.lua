local BoxOpeningPopup = {
  Properties = {
    MasterContainer = {
      default = EntityId()
    },
    ItemsContainer = {
      default = EntityId()
    },
    NextBoxButtonPrototype = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    NextButton = {
      default = EntityId()
    },
    BackgroundElements = {
      default = EntityId()
    },
    FullScreenOverlay = {
      default = EntityId()
    },
    CenterStrip = {
      default = EntityId()
    },
    RunesMask = {
      default = EntityId()
    },
    RuneA = {
      default = EntityId()
    },
    RuneB = {
      default = EntityId()
    },
    RuneC = {
      default = EntityId()
    },
    RarityFlames = {
      default = EntityId()
    },
    Tier4Flames = {
      default = EntityId()
    },
    Tier3Flames = {
      default = EntityId()
    },
    NextBoxButtonsContainer = {
      default = EntityId()
    },
    Scrollbox = {
      default = EntityId()
    }
  },
  maxEntries = 10,
  maxRewardBoxButtons = 10,
  boxButtonSize = 120,
  padding = 10,
  delayBetweenEntries = 0.25,
  multiRowYOffset = 120,
  multiRowEntryScale = 0.6,
  itemQueue = {},
  hasGameEvent = false,
  bgflamedelay = 1.25,
  isOpeningBox = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(BoxOpeningPopup)
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function BoxOpeningPopup:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.Scrollbox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.Scrollbox)
  self.dataLayer:RegisterOpenEvent("BoxOpeningPopup", self.canvasId)
  DynamicBus.BoxOpeningPopup.Connect(self.entityId, self)
  self.NextButton:SetButtonStyle(self.NextButton.BUTTON_STYLE_CTA)
  self.NextButton:SetCallback(self.OnOpenNextBoxInOrder, self)
  self.NextButton:SetText("@ui_box_opening_open_another_single")
  self.CloseButton:SetButtonStyle(self.CloseButton.BUTTON_STYLE_DEFAULT)
  self.CloseButton:SetText("@ui_close")
  self.CloseButton:SetCallback(self.OnClose, self)
  self:BusConnect(LyShineScriptBindNotificationBus, self.canvasId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryEntityId)
    self.inventoryEntityId = inventoryEntityId
  end)
  local prototypeItem = UiElementBus.Event.GetChild(self.Properties.ItemsContainer, 0)
  for i = 2, self.maxEntries do
    CloneUiElement(self.canvasId, self.registrar, prototypeItem, self.Properties.ItemsContainer, false)
  end
  self.entryContainerWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ItemsContainer)
  self.entryWidth = UiTransform2dBus.Event.GetLocalWidth(prototypeItem)
  self:CacheAnimations()
end
function BoxOpeningPopup:CacheAnimations()
  if not self.anim then
    self.anim = {}
  end
  self.anim.slideOutLeft = self.ScriptedEntityTweener:CacheAnimation(0.25, {
    opacity = 0,
    x = -100,
    ease = "QuadOut"
  })
end
function BoxOpeningPopup:OnShutdown()
  BaseScreen.OnShutdown(self)
  timingUtils:StopDelay(self)
  DynamicBus.BoxOpeningPopup.Disconnect(self.entityId, self)
end
function BoxOpeningPopup:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.isVisible = true
  self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RuneA, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RuneB, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RuneC, {opacity = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.MasterContainer, 0.2, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:Play(self.Properties.RuneA, 240, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  self.ScriptedEntityTweener:Play(self.Properties.RuneB, 90, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  self.ScriptedEntityTweener:Play(self.Properties.RuneC, 180, {rotation = 0}, {timesToPlay = -1, rotation = -359})
  self.ScriptedEntityTweener:PlayC(self.Properties.RuneB, 0.5, tweenerCommon.fadeInQuadOut, 0.5)
  self.ScriptedEntityTweener:PlayC(self.Properties.RuneC, 0.5, tweenerCommon.fadeInQuadOut, 0.6)
  self.ScriptedEntityTweener:PlayC(self.Properties.RuneA, 0.5, tweenerCommon.fadeInQuadOut, 0.7)
end
function BoxOpeningPopup:showRarityFlames(raritylevel, delay)
  if raritylevel ~= nil and raritylevel < 3 then
    UiElementBus.Event.SetIsEnabled(self.Properties.RarityFlames, false)
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.RarityFlames, true)
  self.ScriptedEntityTweener:Set(self.Properties.RarityFlames, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.Properties.Tier3Flames, raritylevel == 3)
  UiElementBus.Event.SetIsEnabled(self.Properties.Tier4Flames, raritylevel == 4)
  if raritylevel == 3 then
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Tier3Flames, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.Tier3Flames)
  elseif raritylevel == 4 then
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Tier4Flames, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.Tier4Flames)
  end
  local flamesDelay = 0
  if delay then
    flamesDelay = delay + self.bgflamedelay
  else
    flamesDelay = self.bgflamedelay
  end
  self.ScriptedEntityTweener:Play(self.Properties.RarityFlames, 1, {
    opacity = 1,
    ease = "linear",
    delay = flamesDelay
  })
end
function BoxOpeningPopup:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.isVisible = false
  ClearTable(self.itemQueue)
  self.hasGameEvent = false
  self.gameEventData = nil
  self.nextBoxItemInstanceId = nil
  self.isOpeningBox = false
  timingUtils:StopDelay(self)
  DynamicBus.BoxOpeningPopupNotifications.Broadcast.OnBoxOpeningPopupClosed()
end
function BoxOpeningPopup:OnClose()
  self.ScriptedEntityTweener:PlayC(self.Properties.MasterContainer, 0.2, tweenerCommon.fadeOutQuadOut, nil, function()
    self.dataLayer:SetScreenEnabled("BoxOpeningPopup", false)
  end)
end
function BoxOpeningPopup:OnOpenNextBox(itemData)
  self:OnPickNextBoxToOpen(itemData.itemInstanceId)
end
function BoxOpeningPopup:OnOpenNextBoxInOrder()
  if not self.nextBoxItemInstanceId then
    return
  end
  self:OnPickNextBoxToOpen(self.nextBoxItemInstanceId)
end
function BoxOpeningPopup:OnPickNextBoxToOpen(itemInstanceId)
  if self.isOpeningBox then
    return
  end
  self.isOpeningBox = true
  self.ScriptedEntityTweener:PlayC(self.Properties.RarityFlames, 0.25, tweenerCommon.fadeOutLinear)
  self.ScriptedEntityTweener:PlayC(self.Properties.ItemsContainer, 0.25, self.anim.slideOutLeft, nil, function()
    local inventorySlotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryEntityId, itemInstanceId)
    if 0 <= inventorySlotId then
      local itemSlot = ContainerRequestBus.Event.GetSlotRef(self.inventoryEntityId, inventorySlotId)
      self:SetRewardBoxGameEventId(itemSlot:GetItemId())
      LocalPlayerUIRequestsBus.Broadcast.SalvageItem(inventorySlotId, 1, self.inventoryEntityId)
    end
    self.isOpeningBox = false
  end)
end
function BoxOpeningPopup:HideBoxOpeningPopup()
  if self.isVisible then
    self:OnClose()
  end
end
function BoxOpeningPopup:SetRewardBoxGameEventId(rewardBoxItemId)
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(rewardBoxItemId)
  self.hasGameEvent = itemData.salvageGameEventId ~= 0
  if self.hasGameEvent and not self.gameEventHandler then
    self.gameEventHandler = self:BusConnect(GameEventUiNotificationBus)
  end
end
function BoxOpeningPopup:OnUiGameEvent(gameEventId, modifier, currencyReward, receivedAzothReward)
  self.gameEventData = {currencyReward = currencyReward, receivedAzothReward = receivedAzothReward}
  if receivedAzothReward then
    local staticEventData = GameEventRequestBus.Broadcast.GetGameSystemData(gameEventId)
    self.gameEventData.azothReward = staticEventData.azothReward
  end
  self:BusDisconnect(self.gameEventHandler)
  self.gameEventHandler = nil
  timingUtils:StopDelay(self)
  timingUtils:Delay(0.1, self, self.TryShowRewardItems)
end
function BoxOpeningPopup:OnRewardChestOpened(itemSlot, quantity)
  table.insert(self.itemQueue, {
    itemInstanceId = itemSlot:GetItemInstanceId(),
    quantity = quantity
  })
  timingUtils:StopDelay(self)
  timingUtils:Delay(0.1, self, self.TryShowRewardItems)
end
function BoxOpeningPopup:TryShowRewardItems()
  if self.hasGameEvent and not self.gameEventData then
    return
  end
  local numItems = #self.itemQueue
  if numItems == 0 then
    return
  end
  local otherRewards = {}
  if self.hasGameEvent then
    if 0 < self.gameEventData.currencyReward then
      table.insert(otherRewards, {
        quantity = self.gameEventData.currencyReward,
        isAzoth = false
      })
    end
    if self.gameEventData.azothReward then
      table.insert(otherRewards, {
        quantity = self.gameEventData.azothReward,
        isAzoth = true
      })
    end
  end
  local numOtherRewards = #otherRewards
  local totalEntries = numItems + numOtherRewards
  local numLine1Entries = totalEntries
  local itemOffsetX = self.entryWidth + self.padding
  local totalWidth = totalEntries * self.entryWidth + (totalEntries - 1) * self.padding
  local line1StartX = (self.entryContainerWidth - totalWidth) / 2
  local line2StartX = 0
  local entryScale = 1
  local delay = 0
  local isMultiLine = 5 < totalEntries
  if isMultiLine then
    numLine1Entries = math.ceil(totalEntries / 2)
    entryScale = self.multiRowEntryScale
    local entryWidth = self.entryWidth * entryScale
    itemOffsetX = entryWidth + self.padding
    totalWidth = numLine1Entries * entryWidth + (numLine1Entries - 1) * self.padding
    line1StartX = (self.entryContainerWidth - totalWidth) / 2
    local numLine2Entries = totalEntries - numLine1Entries
    local line2Width = numLine2Entries * entryWidth + (numLine2Entries - 1) * self.padding
    line2StartX = (self.entryContainerWidth - line2Width) / 2
  end
  local highestRarityLevel = -1
  local children = UiElementBus.Event.GetChildren(self.Properties.ItemsContainer)
  for i = 1, #children do
    local entryTable = self.registrar:GetEntityTable(children[i])
    if i <= totalEntries then
      local pos = Vector2(0, 0)
      if isMultiLine then
        if i <= numLine1Entries then
          pos.x = line1StartX + (i - 1) * itemOffsetX
          pos.y = -self.multiRowYOffset
        else
          pos.x = line2StartX + (i - numLine1Entries - 1) * itemOffsetX
          pos.y = self.multiRowYOffset
        end
      else
        pos.x = line1StartX + (i - 1) * itemOffsetX
      end
      local entryData = {
        pos = pos,
        scale = entryScale,
        delay = delay
      }
      if i <= numItems then
        local itemData = self.itemQueue[i]
        local inventorySlotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryEntityId, itemData.itemInstanceId)
        entryData.itemSlot = ContainerRequestBus.Event.GetSlotRef(self.inventoryEntityId, inventorySlotId)
        entryData.quantity = itemData.quantity
      elseif numOtherRewards >= i - numItems then
        local otherRewardData = otherRewards[i - numItems]
        entryData.quantity = otherRewardData.quantity
        entryData.isAzoth = otherRewardData.isAzoth
      end
      local raritylevel = entryTable:ShowBoxOpeningItem(entryData)
      highestRarityLevel = math.max(raritylevel, highestRarityLevel)
      delay = delay + self.delayBetweenEntries
      self:showRarityFlames(highestRarityLevel, delay)
    else
      entryTable:HideBoxOpeningItem()
    end
  end
  local containerScale = 1
  if totalWidth > self.entryContainerWidth then
    containerScale = self.entryContainerWidth / totalWidth
  end
  self.ScriptedEntityTweener:Set(self.Properties.ItemsContainer, {opacity = 1, x = 0})
  UiTransformBus.Event.SetScale(self.Properties.ItemsContainer, Vector2(containerScale, containerScale))
  local rewardBoxSlots = ContainerRequestBus.Event.GetFilteredContent(self.inventoryEntityId, eItemClass_LootContainer, false, false)
  local numRewardBoxSlots = #rewardBoxSlots
  local numRewardBoxes = 0
  for i = 1, numRewardBoxSlots do
    numRewardBoxes = numRewardBoxes + rewardBoxSlots[i]:GetStackSize()
  end
  self.listItemData = {}
  if 0 < numRewardBoxes then
    UiElementBus.Event.SetIsEnabled(self.Properties.NextBoxButtonsContainer, true)
    for i = 1, numRewardBoxSlots do
      local rewardBoxSlot = rewardBoxSlots[i]
      if i == 1 then
        self.nextBoxItemInstanceId = rewardBoxSlot:GetItemInstanceId()
      end
      table.insert(self.listItemData, {
        itemInstanceId = rewardBoxSlot:GetItemInstanceId(),
        iconPath = rewardBoxSlot:GetIconPath(),
        stackSize = rewardBoxSlot:GetStackSize(),
        callbackSelf = self,
        onClickCallback = self.OnOpenNextBox
      })
    end
    local maxItems = math.min(numRewardBoxSlots, self.maxRewardBoxButtons)
    local maxScrollboxWidth = maxItems * self.boxButtonSize
    if numRewardBoxes < maxItems then
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.Scrollbox, numRewardBoxes * self.boxButtonSize)
    else
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.Scrollbox, maxScrollboxWidth)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.NextButton, true)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.CloseButton, -160)
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Scrollbox)
  if numRewardBoxes == 0 then
    UiElementBus.Event.SetIsEnabled(self.Properties.NextButton, false)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.CloseButton, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.NextBoxButtonsContainer, false)
  end
  ClearTable(self.itemQueue)
  self.hasGameEvent = false
  self.gameEventData = nil
  if not self.isVisible then
    self.dataLayer:SetScreenEnabled("BoxOpeningPopup", true)
  end
end
function BoxOpeningPopup:GetNumElements()
  if not self.listItemData then
    return 0
  end
  return #self.listItemData
end
function BoxOpeningPopup:OnElementBecomingVisible(rootEntity, index)
  if not self.listItemData then
    return
  end
  local itemRowTable = self.registrar:GetEntityTable(rootEntity)
  local boxData = self.listItemData[index + 1]
  itemRowTable:SetGridItemData(boxData)
end
return BoxOpeningPopup
