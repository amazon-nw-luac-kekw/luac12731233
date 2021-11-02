local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local CatSection = {
  Properties = {
    Header = {
      default = EntityId()
    },
    List = {
      default = EntityId()
    },
    TransferAll = {
      default = EntityId()
    },
    RepairAll = {
      default = EntityId()
    },
    HorzSpacing = {default = 2},
    VertSpacing = {default = 5},
    Footer = {
      default = EntityId()
    },
    FilteredText = {
      default = EntityId()
    }
  },
  itemDefs = {},
  slotIdsToItemDefs = {},
  filterNeedsUpdating = false,
  visibilityBuffer = 60,
  itemWidth = 60,
  itemHeight = 60,
  rowHeight = 65,
  colWidth = 62,
  itemsPerRow = 4,
  totalWeight = 0,
  unfilteredCount = 0,
  firstVisibleItem = -1,
  lastVisibleItem = -1,
  filterVersion = -1,
  dynamicItemList = nil,
  repairAllEnabled = true,
  useSections = true
}
BaseElement:CreateNewElement(CatSection)
local InventoryUtility = RequireScript("LyShineUI.Automation.Utilities.InventoryUtility")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function CatSection:OnInit()
  BaseElement.OnInit(self)
  self.TransferAll:SetCallback("OnTransferAllButton", self)
  UiElementBus.Event.SetIsEnabled(self.Properties.TransferAll, false)
  self.showTransferAllButton = false
  self.TransferAll:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_smallArrowNarrow.png")
  self.ScriptedEntityTweener:Set(self.TransferAll.Properties.ButtonSingleIcon, {scaleX = 0.5})
  if self.Properties.RepairAll:IsValid() then
    self.RepairAll:SetCallback("OnRepairAllButton", self)
    UiElementBus.Event.SetIsEnabled(self.Properties.RepairAll, true)
    self.RepairAll:SetButtonSingleIconColor(self.UIStyle.COLOR_GRAY_60)
    self.RepairAll:SetButtonSingleIconFocusColor(self.UIStyle.COLOR_WHITE)
    self.RepairAll:SetButtonSingleIconPath("lyshineui/images/icons/tooltip/icon_tooltip_repair.png")
    self.RepairAll:SetTooltip("@ui_repair_all")
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ContainerCanTransferChange", function(self, containerCanTransferChange)
    local catTransferEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableCategoryTransfer")
    if catTransferEnabled and self.showTransferAllButton then
      self:UpdateEnabledState()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ActiveContainer", function(self, activeContainerId)
    if not activeContainerId then
      return
    end
    local catTransferEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableCategoryTransfer")
    if catTransferEnabled and self.showTransferAllButton then
      if activeContainerId:IsValid() then
        local canTransfer = activeContainerId and ContainerRequestBus.Event.CanTransferItems(activeContainerId)
        if canTransfer then
          self:UpdateEnabledState()
        end
      else
        self:UpdateEnabledState()
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.Footer, false)
  self.Header:SetTextWeight(self.totalWeight / 10)
end
function CatSection:UpdateEnabledState()
  local canTransfer = self.canTransferAllCallback(self.dynamicItemList, self.itemClass) and self.filter:IsClear()
  self.TransferAll:SetEnabled(canTransfer)
end
function CatSection:OnShutdown()
  self.dynamicItemList = nil
end
function CatSection:SetTransferAllText(text)
  self.TransferAll:SetTooltip(text)
  self.showTransferAllButton = true
end
function CatSection:SetButtonArrowDirection(direction)
  self.ScriptedEntityTweener:Set(self.TransferAll.Properties.ButtonSingleIcon, {scaleX = direction})
end
function CatSection:SetTransferAllInfo(caller, canTransferFn, transferFn, itemClass)
  self.dynamicItemList = caller
  self.transferAllCallback = transferFn
  self.canTransferAllCallback = canTransferFn
  self.itemClass = itemClass
  if itemClass == eItemClass_UI_Weapon or itemClass == eItemClass_UI_Tools then
    self.itemWidth = self.UIStyle.ITEM_LAYOUT_SQUARE_WIDTH
    self.itemHeight = self.UIStyle.ITEM_LAYOUT_SQUARE_WIDTH
    self.itemsPerRow = 4
  else
    self.itemWidth = self.UIStyle.ITEM_LAYOUT_CIRCLE_WIDTH
    self.itemHeight = self.UIStyle.ITEM_LAYOUT_CIRCLE_HEIGHT
    self.itemsPerRow = 4
  end
  self.colWidth = self.itemWidth + self.Properties.HorzSpacing
  self.rowHeight = self.itemHeight + self.Properties.VertSpacing
end
function CatSection:OnTransferAllButton()
  if self.dynamicItemList then
    self.transferAllCallback(self.dynamicItemList, self.itemClass)
  end
end
function CatSection:SetRepairAllEnabled(active)
  self.repairAllEnabled = active
  if self.Properties.RepairAll:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.RepairAll, active)
    self.ScriptedEntityTweener:Set(self.Header.Properties.HeaderWeight, {
      x = active and -60 or -30
    })
    self.ScriptedEntityTweener:Set(self.Header.Properties.HeaderWeightIcon, {
      x = active and -60 or -30
    })
  end
end
function CatSection:SetRepairAllActive(active, hasDamagedItems)
  if self.Properties.RepairAll:IsValid() then
    local isEnabled = active and hasDamagedItems
    self.RepairAll:SetEnabled(isEnabled)
    self.RepairAll:SetButtonSingleIconColor(isEnabled and self.UIStyle.COLOR_GRAY_60 or self.UIStyle.COLOR_GRAY_30)
    if hasDamagedItems then
      self.RepairAll:SetTooltip(active and "@ui_repair_all" or "@ui_repair_all_category_disabled")
    else
      self.RepairAll:SetTooltip("@ui_repair_all_not_needed")
    end
  end
end
function CatSection:OnRepairAllButton()
  if self.repairAllEnabled then
    local repairConfirmation = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_repair_all_confirmation")
    local totalRepairKits = 0
    for i = 1, #self.totalRepairCost.repairKits do
      totalRepairKits = totalRepairKits + self.totalRepairCost.repairKits[i]
    end
    if 0 < totalRepairKits then
      repairConfirmation = repairConfirmation .. "\n" .. LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@inv_repair_kit_count", totalRepairKits)
    end
    if 0 < self.totalRepairCost.coin then
      repairConfirmation = repairConfirmation .. "\n" .. LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_currency_value", GetLocalizedCurrency(self.totalRepairCost.coin))
    end
    if 0 < self.totalRepairCost.repairParts then
      repairConfirmation = repairConfirmation .. "\n" .. LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@inv_repairparts_quantity", self.totalRepairCost.repairParts)
    end
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_repair_all", repairConfirmation, "repairAll", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        local repairEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ItemRepairEntityId")
        ItemRepairRequestBus.Event.RepairAllItemClass(repairEntityId, self.itemClass)
      end
    end)
  end
end
function CatSection:ClearAll()
  for i, itemDef in ipairs(self.itemDefs) do
    if itemDef.entityId then
      UiElementBus.Event.SetIsEnabled(itemDef.entityId, false)
      self.dynamicItemList:ReturnItemSpawn(itemDef.entityId)
    end
  end
  self.totalWeight = 0
  self.Header:SetTextWeight(0)
  ClearTable(self.itemDefs)
  ClearTable(self.slotIdsToItemDefs)
  self.unfilteredCount = 0
end
function CatSection:SetGlobalStorageId(id)
  self.globalStorageId = id
  self:ClearAll()
end
function CatSection:MakeItemContainerSlotCallback(itemDef)
  return function()
    local slot
    if self.globalStorageId then
      local itemSlots = GlobalStorageRequestBus.Event.GetStorageContents(self.playerEntityId, self.globalStorageId)
      if itemSlots and #itemSlots >= itemDef.localSlotId then
        return itemSlots[itemDef.localSlotId]
      end
    else
      return itemDef.slot
    end
    return nil
  end
end
function CatSection:UpdateItemDef(itemDef, slot)
  itemDef.weight = slot:GetWeight()
  itemDef.chrono = slot:GetContainerChrono()
  itemDef.itemDescriptor = slot:GetItemDescriptor()
  itemDef.isContainer = slot:HasItemClass(eItemClass_LootContainer)
  itemDef.gearScore = nil
  itemDef.displayName = nil
  itemDef.tier = slot:GetTierNumber()
end
function CatSection:DoSlotUpdate(localSlotId, slot, useSections)
  local needDelete = false
  self.useSections = useSections
  if not slot or not slot:IsValid() then
    needDelete = true
  elseif self.useSections then
    needDelete = not slot:HasItemClass(self.itemClass)
  else
    local itemClass = self.itemClass
    needDelete = itemClass ~= eItemClass_UI_Weapon
  end
  local itemDef = self.slotIdsToItemDefs[localSlotId]
  if itemDef then
    self.filterNeedsUpdating = true
    if needDelete then
      self.slotIdsToItemDefs[localSlotId] = nil
      for i, itemDef in ipairs(self.itemDefs) do
        if itemDef.localSlotId == localSlotId then
          if itemDef.entityId then
            UiElementBus.Event.SetIsEnabled(itemDef.entityId, false)
            self.dynamicItemList:ReturnItemSpawn(itemDef.entityId)
          end
          self.totalWeight = self.totalWeight - (itemDef.weight or 0)
          table.remove(self.itemDefs, i)
          break
        end
      end
    else
      self.totalWeight = self.totalWeight - (itemDef.weight or 0)
      if not self.globalStorageId then
        itemDef.slot = slot
      end
      self:UpdateItemDef(itemDef, slot)
      self.totalWeight = self.totalWeight + itemDef.weight
      if itemDef.entityId then
        DynamicBus.ItemLayoutSlotProvider.Event.SetItemAndSlotProvider(itemDef.entityId, slot, tostring(localSlotId), self:MakeItemContainerSlotCallback(itemDef))
      end
    end
  elseif not needDelete then
    self.filterNeedsUpdating = true
    local itemDef = {localSlotId = localSlotId}
    self:UpdateItemDef(itemDef, slot)
    if not self.globalStorageId then
      itemDef.slot = slot
    end
    self.totalWeight = self.totalWeight + itemDef.weight
    table.insert(self.itemDefs, itemDef)
    self.slotIdsToItemDefs[localSlotId] = itemDef
  end
  self.Header:SetTextWeight(self.totalWeight / 10)
  if self.Properties.RepairAll:IsValid() and self.repairAllEnabled then
    self:ComputeRepairAllAmount()
  end
end
function CatSection:ComputeRepairAllAmount()
  local repairEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ItemRepairEntityId")
  self.totalRepairCost = ItemRepairRequestBus.Event.GetCostForRepairAllItemClass(repairEntityId, self.itemClass)
  if self.totalRepairCost.hasJobs then
    local hasEnoughKitsAndParts = false
    if self.totalRepairCost.repairParts > 0 or 0 < self.totalRepairCost.coin then
      hasEnoughKitsAndParts = InventoryUtility:GetGold() >= self.totalRepairCost.coin and InventoryUtility:GetRepairParts() >= self.totalRepairCost.repairParts
    else
      hasEnoughKitsAndParts = true
    end
    self:SetRepairAllActive(hasEnoughKitsAndParts, true)
  else
    self:SetRepairAllActive(false, false)
  end
end
function CatSection:UpdateFilter()
  if self.filter and (self.filterNeedsUpdating or self.filterVersion ~= self.filter.version) then
    self.unfilteredCount = self.filter:FilterAndSortItemDefs(self.itemDefs)
    self.filterVersion = self.filter.version
    self.filterNeedsUpdating = false
    for i, itemDef in ipairs(self.itemDefs) do
      if itemDef.entityId then
        DynamicBus.ItemFilterNotificationBus.Event.OnFilterChange(itemDef.entityId, self.filter)
      end
    end
  end
end
function CatSection:SetHiddenWhenEmpty(hideWhenEmpty)
  self.hideWhenEmpty = true
end
function CatSection:SetTop(top)
  self:UpdateFilter()
  local height = math.ceil(self.unfilteredCount / self.itemsPerRow) * self.rowHeight
  local sectionOffsets = UiTransform2dBus.Event.GetOffsets(self.entityId)
  local listOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.List)
  local headerOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Header)
  local numItems = #self.itemDefs
  local showHeader = 0 < numItems or not self.hideWhenEmpty
  if not self.useSections then
    showHeader = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Header, showHeader)
  if showHeader then
    local margin = 5
    listOffsets.top = headerOffsets.bottom + margin
  else
    listOffsets.top = headerOffsets.top
  end
  listOffsets.bottom = listOffsets.top + height
  if top then
    sectionOffsets.top = top
  end
  sectionOffsets.bottom = sectionOffsets.top + listOffsets.bottom
  if numItems > self.unfilteredCount then
    local footerOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Footer)
    local footerHeight = footerOffsets.bottom - footerOffsets.top
    footerOffsets.top = listOffsets.bottom
    footerOffsets.bottom = footerOffsets.top + footerHeight
    UiTransform2dBus.Event.SetOffsets(self.Properties.Footer, footerOffsets)
    UiElementBus.Event.SetIsEnabled(self.Properties.Footer, true)
    sectionOffsets.bottom = sectionOffsets.bottom + footerHeight
    local filteredCount = numItems - self.unfilteredCount
    local filteredText = GetLocalizedReplacementText("@ui_filtereditems", {
      filtered = tostring(filteredCount),
      total = tostring(numItems)
    })
    UiTextBus.Event.SetText(self.Properties.FilteredText, filteredText)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Footer, false)
  end
  UiTransform2dBus.Event.SetOffsets(self.entityId, sectionOffsets)
  UiTransform2dBus.Event.SetOffsets(self.Properties.List, listOffsets)
  local catTransferEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableCategoryTransfer")
  UiElementBus.Event.SetIsEnabled(self.Properties.TransferAll, catTransferEnabled and self.showTransferAllButton and 0 < height)
  if catTransferEnabled and self.showTransferAllButton and 0 < height then
    local canTransfer = self.canTransferAllCallback(self.dynamicItemList, self.itemClass) and self.filter:IsClear()
    self.TransferAll:SetEnabled(canTransfer)
  end
  return sectionOffsets.bottom, #self.itemDefs
end
function CatSection:UpdateOnScreenItems(scrollPos, scrollHeight)
  local sectionParent = UiElementBus.Event.GetParent(self.entityId)
  local parentWidth = UiTransform2dBus.Event.GetLocalWidth(sectionParent)
  local sectionOffsets = UiTransform2dBus.Event.GetOffsets(self.entityId)
  local listOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.List)
  local sectionAnchors = UiTransform2dBus.Event.GetAnchors(self.entityId)
  local listTop = sectionOffsets.top + listOffsets.top
  local listLeft = sectionOffsets.left + sectionAnchors.left * parentWidth + listOffsets.left
  self:UpdateFilter()
  self.firstVisibleItem = self.unfilteredCount + 1
  self.lastVisibleItem = 0
  local unfiltered = 0
  for i, itemDef in ipairs(self.itemDefs) do
    if itemDef.isInFilter then
      unfiltered = unfiltered + 1
    end
    local row = math.floor((unfiltered - 1) / self.itemsPerRow)
    local col = (unfiltered - 1) % self.itemsPerRow
    local left = listLeft + col * self.colWidth
    local top = listTop + row * self.rowHeight
    local newChildOffsets = UiOffsets(left, top, left + self.itemWidth, top + self.itemHeight)
    local isOnScreen = itemDef.isInFilter and top >= -scrollPos.y - self.visibilityBuffer and top <= -scrollPos.y + scrollHeight + self.visibilityBuffer
    if isOnScreen then
      self.firstVisibleItem = math.min(i, self.firstVisibleItem)
      self.lastVisibleItem = math.max(i, self.lastVisibleItem)
      if itemDef.entityId then
        if newChildOffsets.top ~= itemDef.offsets.top or newChildOffsets.left ~= itemDef.offsets.left then
          UiElementBus.Event.SetIsEnabled(itemDef.entityId, true)
          UiTransform2dBus.Event.SetOffsets(itemDef.entityId, newChildOffsets)
          UiTransformBus.Event.SetRecomputeFlags(itemDef.entityId, eUiRecompute_RectAndTransformForced)
          itemDef.offsets = newChildOffsets
        end
      else
        itemDef.entityId = self.dynamicItemList:RequestItemSpawn()
        if itemDef.entityId then
          local slot
          if itemDef.slot and not self.globalStorageId then
            slot = itemDef.slot
          else
            local itemSlots = GlobalStorageRequestBus.Event.GetStorageContents(self.playerEntityId, self.globalStorageId)
            if itemSlots and #itemSlots >= itemDef.localSlotId then
              slot = itemSlots[itemDef.localSlotId]
            end
          end
          UiElementBus.Event.SetIsEnabled(itemDef.entityId, true)
          UiTransform2dBus.Event.SetAnchorsScript(itemDef.entityId, UiAnchors(0, 0, 0, 0))
          UiTransform2dBus.Event.SetOffsets(itemDef.entityId, newChildOffsets)
          itemDef.offsets = newChildOffsets
          if slot then
            DynamicBus.ItemLayoutSlotProvider.Event.SetItemAndSlotProvider(itemDef.entityId, slot, tostring(itemDef.localSlotId), self:MakeItemContainerSlotCallback(itemDef))
            DynamicBus.ItemFilterNotificationBus.Event.OnFilterChange(itemDef.entityId, self.filter)
          end
          ItemContainerBus.Event.SetShouldCompare(itemDef.entityId, true)
        end
      end
    elseif itemDef.entityId then
      self.dynamicItemList:ReturnItemSpawn(itemDef.entityId)
      itemDef.entityId = nil
    end
  end
end
return CatSection
