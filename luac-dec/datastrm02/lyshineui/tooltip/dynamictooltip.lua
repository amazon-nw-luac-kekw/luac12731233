local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local jsonParser = RequireScript("LyShineUI.json")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local DynamicTooltip = {
  Properties = {
    Content = {
      default = EntityId()
    },
    ItemName = {
      default = EntityId()
    },
    ItemStats = {
      default = EntityId()
    },
    Required = {
      default = EntityId()
    },
    Flavor = {
      default = EntityId()
    },
    SpecialInstructions = {
      default = EntityId()
    },
    DynamicInfo = {
      default = EntityId()
    },
    Commands = {
      default = EntityId()
    },
    Compare = {
      default = EntityId()
    },
    DisclaimerText = {
      default = EntityId()
    },
    BG = {
      default = EntityId()
    },
    BgRed = {
      default = EntityId()
    },
    DrawnFrame = {
      default = EntityId()
    },
    Column2 = {
      default = EntityId()
    },
    Column2Frame = {
      default = EntityId()
    },
    Column2Fringe = {
      default = EntityId()
    },
    Column2Bg = {
      default = EntityId()
    },
    Column2Header = {
      default = EntityId()
    },
    Column2InputBlocker = {
      default = EntityId()
    },
    FlashSmall = {
      default = EntityId()
    },
    FlashLarge = {
      default = EntityId()
    }
  },
  isDynamicTooltip = true,
  column2HeaderHeight = 49,
  column2BottomMargin = 6,
  column2Width = 180,
  column2CompareWidth = 264
}
BaseElement:CreateNewElement(DynamicTooltip)
function DynamicTooltip:OnInit()
  BaseElement.OnInit(self)
  self.LogSettings = {false, "Tooltips"}
  Log(self.LogSettings, "DynamicTooltip:OnInit with entityId = %s", tostring(self.entityId))
  self.Required:SetCallback(self.SetBgRedVisible, self)
  self.sections = {
    self.ItemName,
    self.ItemStats,
    self.Flavor,
    self.SpecialInstructions,
    self.DynamicInfo,
    self.Required,
    self.DisclaimerText
  }
  local contentOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Content)
  self.contentWidth = contentOffsets.right - contentOffsets.left
  local column2Offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Column2)
  self.column2OriginalWidth = column2Offsets.right - column2Offsets.left
  self.column2Width = self.column2OriginalWidth
  self.dynamicTooltipHandler = DynamicBus.DynamicTooltip.Connect(self.entityId, self)
  self.DrawnFrame:SetLineColor(self.UIStyle.COLOR_TOOLTIP_OUTER_FRAME)
end
function DynamicTooltip:OnShutdown()
  if self.dynamicTooltipHandler then
    DynamicBus.DynamicTooltip.Disconnect(self.entityId, self)
    self.dynamicTooltipHandler = nil
  end
end
function DynamicTooltip:ResizeChildInFrame(frameElement, childElement, newChildHeight, neverShrink, additionalHeight)
  local frameOffsets = UiTransform2dBus.Event.GetOffsets(frameElement)
  local childOffsets = UiTransform2dBus.Event.GetOffsets(childElement)
  local oldHeight = frameOffsets.bottom - frameOffsets.top
  local delta = oldHeight - (childOffsets.bottom - childOffsets.top)
  childOffsets.bottom = childOffsets.top + newChildHeight
  UiTransform2dBus.Event.SetOffsets(childElement, childOffsets)
  local newHeight = newChildHeight + delta + (additionalHeight or 0)
  if neverShrink and oldHeight > newHeight then
    newHeight = oldHeight
  end
  frameOffsets.bottom = frameOffsets.top + newHeight
  UiTransform2dBus.Event.SetOffsets(frameElement, frameOffsets)
  return frameOffsets.bottom - frameOffsets.top
end
function DynamicTooltip:ResizeElementAtY(element, y, height)
  local childOffsets = UiTransform2dBus.Event.GetOffsets(element)
  childOffsets.top = y
  childOffsets.bottom = y + height
  UiTransform2dBus.Event.SetOffsets(element, childOffsets)
  return childOffsets.bottom
end
function DynamicTooltip:ResizeTextAtY(textElement, y)
  local textSize = UiTextBus.Event.GetTextSize(textElement)
  return self:ResizeElementAtY(textElement, y, textSize.y)
end
function DynamicTooltip:ResizeTextInFrame(frameElement, textElement, neverShrink, additionalHeight)
  local textSize = UiTextBus.Event.GetTextSize(textElement)
  return self:ResizeChildInFrame(frameElement, textElement, textSize.y, neverShrink, additionalHeight)
end
function DynamicTooltip:GetSpritePathname(spritePath)
  if type(spritePath) ~= "string" then
    return ""
  end
  local newPath, count = string.gsub(spritePath, "{TTI}", "LyShineUI\\Images\\TooltipImages")
  if newPath ~= spritePath then
    return newPath
  end
  newPath = string.gsub(spritePath, "{ItemIcons}", "LyShineUI\\Images\\Icons\\Items_HiRes")
  if newPath ~= spritePath then
    return newPath
  end
  newPath = string.gsub(spritePath, "{Icons}", "LyShineUI\\Images\\Icons")
  if newPath ~= spritePath then
    return newPath
  end
  return spritePath
end
function DynamicTooltip:SetData(data)
  local itemTable = data.itemTable
  if itemTable then
    if data.itemInstanceId then
      itemTable.itemInstanceId = data.itemInstanceId
    end
    itemTable.owgAvailableItem = data.owgAvailableItem
    itemTable.dynamicInfoColor = data.dynamicInfoColor
    itemTable.dynamicInfoText = data.dynamicInfoText
    itemTable.disclaimerText = data.disclaimerText
    itemTable.availableProducts = data.availableProducts
    itemTable.rewardType = data.rewardType
    itemTable.rewardKey = data.rewardKey
    itemTable.itemId = data.itemId
  elseif not itemTable then
    local descriptor = ItemDescriptor()
    descriptor.itemId = data.itemId
    itemTable = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  end
  self.shopTable = data.shopTable
  self.inventoryTable = data.inventoryTable
  self.draggableItem = data.draggableItem
  if itemTable then
    self:SetItem(itemTable, data, data.showInstantly)
  end
end
function DynamicTooltip:SetFlyoutOnRight(isOnRight)
  if self.flyoutOnRight == isOnRight then
    return
  end
  self.flyoutOnRight = isOnRight
  local contentOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Content)
  local column2Offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Column2)
  local column2Enabled = UiElementBus.Event.IsEnabled(self.Properties.Column2)
  local column2Width = column2Enabled and self.column2Width or 0
  if isOnRight then
    column2Offsets.left = 0
    column2Offsets.right = column2Width
    contentOffsets.left = column2Width
    contentOffsets.right = column2Width + self.contentWidth
    UiImageBus.Event.SetSpritePathname(self.Column2Frame, "LyShineUI/Images/tooltip/tooltip_bgFrameRight.png")
    UiTransform2dBus.Event.SetOffsets(self.Properties.Column2Fringe, UiOffsets(-14, -16, 0, 17))
    self.ScriptedEntityTweener:Set(self.Properties.Column2Fringe, {scaleX = 1})
  else
    contentOffsets.left = 0
    contentOffsets.right = self.contentWidth
    column2Offsets.left = self.contentWidth
    column2Offsets.right = self.contentWidth + column2Width
    UiImageBus.Event.SetSpritePathname(self.Column2Frame, "LyShineUI/Images/tooltip/tooltip_bgFrameLeft.png")
    UiTransform2dBus.Event.SetOffsets(self.Properties.Column2Fringe, UiOffsets(0, -16, 13, 17))
    self.ScriptedEntityTweener:Set(self.Properties.Column2Fringe, {scaleX = -1})
  end
  UiTransform2dBus.Event.SetOffsets(self.Properties.Content, contentOffsets)
  UiTransform2dBus.Event.SetOffsets(self.Properties.Column2, column2Offsets)
  self.Compare:SetFlyoutOnRight(isOnRight)
end
function DynamicTooltip:StopOpenSound()
  self.ScriptedEntityTweener:Stop(self.entityId)
end
local comparableItemTypes = {
  [itemCommon.ITEM_TYPE_AMMO] = true,
  [itemCommon.ITEM_TYPE_ARMOR] = true,
  [itemCommon.ITEM_TYPE_WEAPON] = true
}
local comparableItemSlotTypes = {
  ePaperDollSlotTypes_Head,
  ePaperDollSlotTypes_Chest,
  ePaperDollSlotTypes_Hands,
  ePaperDollSlotTypes_Legs,
  ePaperDollSlotTypes_Feet,
  ePaperDollSlotTypes_Amulet,
  ePaperDollSlotTypes_Token,
  ePaperDollSlotTypes_Ring,
  ePaperDollSlotTypes_Arrow,
  ePaperDollSlotTypes_Cartridge,
  ePaperDollSlotTypes_OffHandOption1,
  ePaperDollSlotTypes_MainHandOption1,
  ePaperDollSlotTypes_MainHandOption2,
  ePaperDollSlotTypes_MainHandOption3,
  ePaperDollSlotTypes_Chopping,
  ePaperDollSlotTypes_Cutting,
  ePaperDollSlotTypes_Dressing,
  ePaperDollSlotTypes_Mining,
  ePaperDollSlotTypes_Fishing,
  ePaperDollSlotTypes_AzothStaff
}
function DynamicTooltip:SetItem(itemTable, data, showInstantly)
  self.column2Width = self.column2OriginalWidth
  self.DrawnFrame:ResetLines()
  self:SetBgRedVisible(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Column2Header, true)
  local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
  local slotId, equipSlot
  if paperdollId and itemTable.itemInstanceId then
    slotId = PaperdollRequestBus.Event.GetSlotIdByItemInstanceId(paperdollId, itemTable.itemInstanceId)
    equipSlot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotId)
  end
  local compareTo = data and data.compareTo or nil
  local slotIndex = data and data.slotIndex or nil
  local isInInventory = data and data.inventoryTable ~= nil and not data.isInPaperdoll or nil
  local isInPaperdoll = data and data.isInPaperdoll or nil
  local allowExternalCompare = data and data.allowExternalCompare or nil
  local isFixedToAnotherTooltip = data and data.isFixed
  if (allowExternalCompare or data.doDefaultCompare) and not compareTo and not isInPaperdoll then
    local itemType = itemTable.itemType
    if comparableItemTypes[itemType] then
      local comparableItems = {}
      for _, slotType in ipairs(comparableItemSlotTypes) do
        local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, slotType)
        local shouldCompare, tdi = StaticItemDataManager:ShouldTooltipCompare(itemTable, slot)
        if shouldCompare then
          tdi.deathDurabilityPenalty = slot:GetOnDeathDurabilityPenalty()
          table.insert(comparableItems, tdi)
        end
      end
      for _, tdi in ipairs(comparableItems) do
        if not compareTo or compareTo.gearScore < tdi.gearScore then
          compareTo = tdi
        end
      end
    end
  end
  local myOffsets = UiTransform2dBus.Event.GetOffsets(self.entityId)
  local myHeight = myOffsets.bottom - myOffsets.top
  local contentOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Content)
  if not self.padding then
    self.padding = myHeight - (contentOffsets.bottom - contentOffsets.top)
  end
  self.audioHelper:PlaySound(self.audioHelper.Tooltip_Show)
  local initialDelay = 0
  self.ScriptedEntityTweener:PlayFromC(self.entityId, showInstantly and 0 or 0.25, {opacity = 0}, tweenerCommon.fadeInQuadIn, initialDelay)
  local animDuration = showInstantly and 0 or 0.2
  local animDelay = showInstantly and 0 or 0.03 + initialDelay
  local contentHeight = 0
  local enabledSections = 0
  for k, section in ipairs(self.sections) do
    section.parent = self
    local sectionHeight = section:SetItem(itemTable, equipSlot, compareTo)
    local enableSection = 0 < sectionHeight
    if 0 < sectionHeight then
      local sectionOffsets = UiTransform2dBus.Event.GetOffsets(section.entityId)
      sectionOffsets.top = contentHeight
      sectionOffsets.bottom = contentHeight + sectionHeight
      UiTransform2dBus.Event.SetOffsets(section.entityId, sectionOffsets)
      contentHeight = contentHeight + sectionHeight
      self.ScriptedEntityTweener:PlayFromC(section.entityId, animDuration, {opacity = 0}, tweenerCommon.fadeInQuadOut, animDelay)
      if not showInstantly then
        animDelay = animDelay + 0.08
      end
    end
    UiElementBus.Event.SetIsEnabled(section.entityId, enableSection)
    enabledSections = enabledSections + (enableSection and 1 or 0)
  end
  local contentWidth = self.contentWidth
  if enabledSections == 1 and UiElementBus.Event.IsEnabled(self.Properties.Flavor) then
    contentWidth = self.Flavor:GetWidth()
    self.Flavor:SetDividerEnabled(false)
  else
    self.Flavor:SetDividerEnabled(true)
  end
  local isCompareListAvailable = self.dataLayer:GetDataFromNode("UIFeatures.enableTooltipCompareList") or allowExternalCompare
  self.Commands.parent = self
  local column2Height = 0
  if not isFixedToAnotherTooltip and (itemTable.itemInstanceId or itemTable.owgAvailableItem or itemTable.availableProducts or allowExternalCompare) then
    local commandsHeight = 0
    if not allowExternalCompare then
      commandsHeight = self.Commands:SetItem(itemTable, equipSlot, compareTo, slotIndex, isInInventory, isInPaperdoll)
    end
    if 0 < commandsHeight then
      local sectionOffsets = UiTransform2dBus.Event.GetOffsets(self.Commands.entityId)
      sectionOffsets.top = 0
      sectionOffsets.bottom = sectionOffsets.top + commandsHeight
      UiTransform2dBus.Event.SetOffsets(self.Commands.entityId, sectionOffsets)
    end
    UiElementBus.Event.SetIsEnabled(self.Commands.entityId, 0 < commandsHeight)
    column2Height = commandsHeight
    self.Compare.parent = self
    local compareHeight = 0
    local minColumn2Height = commandsHeight + self.column2HeaderHeight + self.column2BottomMargin
    if isCompareListAvailable then
      self.column2Width = self.column2CompareWidth
      compareHeight = self.Compare:SetItem(itemTable, equipSlot, compareTo, slotIndex, isInInventory, isInPaperdoll, allowExternalCompare)
      if 0 < compareHeight then
        local sectionOffsets = UiTransform2dBus.Event.GetOffsets(self.Compare.entityId)
        local bottomMargin = 12
        sectionOffsets.top = column2Height
        if contentHeight < minColumn2Height then
          contentHeight = minColumn2Height
        end
        sectionOffsets.bottom = column2Height + compareHeight
        UiTransform2dBus.Event.SetOffsets(self.Compare.entityId, sectionOffsets)
        compareHeight = sectionOffsets.bottom - sectionOffsets.top
        column2Height = column2Height + compareHeight
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Compare.entityId, 0 < compareHeight)
    UiElementBus.Event.SetIsEnabled(self.Properties.Column2Header, compareHeight <= 0)
    column2Height = math.max(minColumn2Height, commandsHeight + compareHeight)
  end
  contentOffsets.bottom = contentOffsets.top + math.max(contentHeight, column2Height)
  local column2Offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Column2)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Column2, self.column2Width)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Column2Bg, self.column2Width)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Column2Frame, self.column2Width + 2)
  local column2Width = column2Offsets.right - column2Offsets.left
  column2Offsets.bottom = column2Offsets.top + math.min(contentHeight, column2Height)
  if column2Height <= self.column2HeaderHeight + self.column2BottomMargin then
    contentOffsets.right = contentWidth
    contentOffsets.left = 0
    myOffsets.right = myOffsets.left + contentWidth
    UiElementBus.Event.SetIsEnabled(self.Column2, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Column2, true)
    contentOffsets.left = self.column2Width
    contentOffsets.right = self.column2Width + contentWidth
    myOffsets.right = myOffsets.left + contentWidth + self.column2Width
    contentHeight = math.max(contentHeight, column2Height)
    UiTransform2dBus.Event.SetLocalHeight(self.Column2Frame, column2Height)
    UiTransform2dBus.Event.SetLocalHeight(self.Column2Bg, column2Height)
  end
  myOffsets.bottom = myOffsets.top + contentHeight + self.padding
  self.DrawnFrame:ResetLines()
  self.DrawnFrame:SetHeight(contentHeight - 1)
  self.DrawnFrame:SetWidth(contentWidth)
  UiTransform2dBus.Event.SetOffsets(self.Properties.Content, contentOffsets)
  UiTransform2dBus.Event.SetOffsets(self.Properties.Column2, column2Offsets)
  UiTransform2dBus.Event.SetOffsets(self.entityId, myOffsets)
  local scale = isFixedToAnotherTooltip and 0.85 or 1
  UiTransformBus.Event.SetScale(self.entityId, Vector2(scale, scale))
  self.flyoutOnRight = nil
  self.lastItemTable = itemTable
  self.lastEquipSlot = equipSlot
  if compareTo and not isFixedToAnotherTooltip and not allowExternalCompare then
    DynamicBus.CompareTooltipRequestBus.Broadcast.ShowTooltip(compareTo, {
      isFixed = true,
      column2Width = self.column2CompareWidth
    }, nil, false)
  end
end
function DynamicTooltip:UpdateSectionsWithoutResize(itemTable, equipSlot, compareTo)
  for k, section in ipairs(self.sections) do
    section:SetItem(itemTable, equipSlot, compareTo)
  end
end
function DynamicTooltip:OnChangeSourceHoverOnly(sourceHoverOnly)
  for k, section in ipairs(self.sections) do
    if type(section.OnChangeSourceHoverOnly) == "function" then
      section:OnChangeSourceHoverOnly(sourceHoverOnly)
    end
  end
end
function DynamicTooltip:OnFlyoutLocked()
  self.DrawnFrame:SetLineVisible(true, 0.5, {delay = 0.2})
  self:PlayActionsFlash()
  for k, section in ipairs(self.sections) do
    if type(section.OnFlyoutLocked) == "function" then
      section:OnFlyoutLocked()
    end
  end
  if type(self.Commands.OnFlyoutLocked) == "function" then
    self.Commands:OnFlyoutLocked()
  end
end
function DynamicTooltip:OnHideTooltip()
  self.DrawnFrame:SetLineVisible(false, 0.1)
  for k, section in ipairs(self.sections) do
    if type(section.OnHideTooltip) == "function" then
      section:OnHideTooltip()
    end
  end
end
function DynamicTooltip:PlayActionsFlash()
  UiElementBus.Event.SetIsEnabled(self.Properties.FlashSmall, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.FlashLarge, true)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashSmall, 0.2, {opacity = 0}, tweenerCommon.tooltipFlashSmallIn)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.FlashLarge, 0.2, {
    opacity = 0,
    scaleX = 0.6,
    scaleY = 0.6
  }, tweenerCommon.tooltipFlashLargeIn)
  self.ScriptedEntityTweener:PlayC(self.Properties.FlashSmall, 1, tweenerCommon.fadeOutQuadOut, 0.2)
  self.ScriptedEntityTweener:PlayC(self.Properties.FlashLarge, 1, tweenerCommon.fadeOutQuadOut, 0.2, function()
    UiElementBus.Event.SetIsEnabled(self.Properties.FlashSmall, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FlashLarge, false)
  end)
end
function DynamicTooltip:SetBgRedVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.BgRed, isVisible)
end
function DynamicTooltip:ResetStatComparison()
  if self.lastItemTable then
    for k, section in ipairs(self.sections) do
      local sectionHeight = section:SetItem(self.lastItemTable, self.lastEquipSlot, nil)
    end
  end
end
return DynamicTooltip
