local DyePicker = {
  Properties = {
    Frame = {
      default = EntityId()
    },
    RecentList = {
      default = EntityId()
    },
    AvailableList = {
      default = EntityId()
    },
    HiddenList = {
      default = EntityId()
    },
    NoDyesText = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    FilterDropdown = {
      default = EntityId()
    }
  },
  colorCount = 0,
  DYE_COLOR_SLICE_PATH = "LyShineUI/Dyes/DyeColor",
  DYE_COLOR_COUNT = 255,
  FILTER_AVAILABLE = 1,
  FILTER_PURCHASABLE = 2,
  FILTER_ALL = 3
}
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DyePicker)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(DyePicker)
local dyePickerCommon = RequireScript("LyShineUI.Dyes.DyePickerCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function DyePicker:OnInit()
  BaseElement.OnInit(self)
  self.filter = self.FILTER_AVAILABLE
  self.FrameHeader:SetText("@ui_colors")
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.AvailableList)
  self.availableColors = {}
  self.recentColors = {}
  self.staticRecentColorData = dyePickerCommon.staticRecentColorData
  local children = UiElementBus.Event.GetChildren(self.Properties.RecentList)
  if children then
    for i = 1, #children do
      local color = self.registrar:GetEntityTable(children[i])
      if color then
        self.recentColors[i] = color
        color:SetCallbacks(self, self.RecentColorSelected, self.OnEntitlementDyeHoverStart)
        color:SetColor(0)
      end
    end
  end
  for i = 1, self.DYE_COLOR_COUNT do
    self:SpawnSlice(self.Properties.AvailableList, self.DYE_COLOR_SLICE_PATH, self.OnDyeColorSpawned, {index = i, count = 0})
  end
  local dropdownData = {
    {
      text = "@ui_show_available",
      id = self.FILTER_AVAILABLE
    },
    {
      text = "@ui_show_purchasable",
      id = self.FILTER_PURCHASABLE
    },
    {
      text = "@ui_show_all",
      id = self.FILTER_ALL
    }
  }
  self.FilterDropdown:SetListData(dropdownData)
  self.FilterDropdown:SetDropdownListHeightByRows(3)
  self.FilterDropdown:SetSelectedItemData(dropdownData[1])
  self.FilterDropdown:SetCallback(self.OnFilterSelect, self)
  self.entitledDyes = {}
  if self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableEntitlements") then
    local entitledDyes = LocalPlayerUIRequestsBus.Broadcast.GetEntitlementDyes()
    for i = 1, #entitledDyes do
      local colorId = entitledDyes[i]
      self.entitledDyes[colorId] = true
    end
  end
end
function DyePicker:OnShutdown()
  dyePickerCommon:Reset()
end
function DyePicker:OnFilterSelect(listItem, listItemData)
  self.filter = listItemData.id
  if self.openCallback then
    self.openCallback(self.openContext)
  end
end
function DyePicker:ResetColors()
  for i = 1, #self.recentColors do
    self.recentColors[i]:SetIsHandlingEvents(false)
  end
  for index, entry in ipairs(self.availableColors) do
    entry.count = 0
    UiElementBus.Event.Reparent(entry.color.entityId, self.Properties.HiddenList, EntityId())
    UiElementBus.Event.SetIsEnabled(entry.color.entityId, false)
  end
  self.colorCount = 0
end
function DyePicker:SetCallback(context, callback)
  self.context = context
  self.callback = callback
end
function DyePicker:SetOpenCallback(context, callback)
  self.openContext = context
  self.openCallback = callback
end
function DyePicker:ToggleVisibilityAndSetCallback(context, callback, startingIndex)
  if self.context == context and self.callback == callback then
    self:SetVisible(not self.isVisible)
  else
    self:SetCallback(context, callback)
    self:SetVisible(true)
  end
  self.startingIndex = startingIndex
end
function DyePicker:SetVisible(isVisible)
  if isVisible == self.isVisible then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.NoDyesText, self.colorCount == 0)
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.15, {opacity = 0}, tweenerCommon.fadeInQuadOut)
    if self.openContext then
      self.openCallback(self.openContext)
    end
    self:RefreshRecentColorDisplay()
  end
  self.isVisible = isVisible
end
function DyePicker:AddColor(index, count, itemId, ap, isNew)
  local entry = self.availableColors[index]
  if entry and entry.color then
    if self.filter == self.FILTER_AVAILABLE and count == 0 then
      return
    end
    if self.filter == self.FILTER_PURCHASABLE and count == 0 and not ap then
      return
    end
    self:OnDyeColorSpawned(entry.color, {
      index = index,
      count = entry.count + count,
      itemId = itemId,
      availableProducts = ap,
      isNew = isNew,
      grantInfo = EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(eRewardTypeItemDye, itemId)
    })
    self.colorCount = self.colorCount + 1
  end
end
function DyePicker:GetCountForColor(index)
  local entry = self.availableColors[index]
  if entry then
    return entry.count
  end
  return 0
end
function DyePicker:RefreshRecentColorDisplay()
  local recentColorIndex = 1
  for i = 1, #self.staticRecentColorData do
    if recentColorIndex > #self.recentColors then
      break
    end
    local recentColorData = self.staticRecentColorData[i]
    if recentColorData then
      local availableColor = self.availableColors[recentColorData.index]
      local validColor = availableColor and availableColor.count > 0
      if validColor then
        self.recentColors[recentColorIndex]:SetColor(recentColorData.index)
        self.recentColors[recentColorIndex]:SetItemId(recentColorData.itemId)
        self.recentColors[recentColorIndex]:SetCount(availableColor.count)
        UiElementBus.Event.SetIsEnabled(self.recentColors[recentColorIndex].entityId, true)
        recentColorIndex = recentColorIndex + 1
      end
    end
  end
  for i = recentColorIndex, #self.recentColors do
    UiElementBus.Event.SetIsEnabled(self.recentColors[i].entityId, false)
  end
end
function DyePicker:OnDyeConfirmed()
  for i = #self.staticRecentColorData, 1, -1 do
    local recentColorData = self.staticRecentColorData[i]
    local validColor = recentColorData and self.availableColors[recentColorData.index].count > 0
    if not validColor then
      table.remove(self.staticRecentColorData, i)
    end
  end
end
function DyePicker:ColorSelected(dyeColor)
  local index = dyeColor.index
  local itemId = dyeColor.itemId
  if dyeColor.count > 0 then
    if self.callback then
      self.callback(self.context, index)
    end
    for dataIndex, colorData in ipairs(self.staticRecentColorData) do
      if colorData.index == index and colorData.itemId == itemId then
        table.remove(self.staticRecentColorData, dataIndex)
        break
      end
    end
    table.insert(self.staticRecentColorData, 1, {index = index, itemId = itemId})
    self:RefreshRecentColorDisplay()
  elseif dyeColor.availableProducts and 0 < #dyeColor.availableProducts then
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    flyoutMenu:SetSourceHoverOnly(false)
    flyoutMenu:Lock()
  end
end
function DyePicker:OnMarkDyeSeen(dyeColor)
  dyeColor:SetIsNew(false)
  EntitlementRequestBus.Broadcast.MarkEntryIdOfRewardTypeSeen(eRewardTypeItemDye, dyeColor.itemId)
end
function DyePicker:OnEntitlementDyeHoverStart(dyeColor)
  local rows = {}
  local displayInfo = EntitlementsDataHandler:GetEntitlementDisplayInfo(eRewardTypeItemDye, dyeColor.index)
  local grantInfo = EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(eRewardTypeItemDye, dyeColor.index)
  local productType = displayInfo.typeString
  local sourceType
  if grantInfo.grantor then
    sourceType = grantInfo.grantor.sourceType
  end
  local row = {
    slicePath = "LyShineUI/Tooltip/DynamicTooltip",
    itemTable = {
      displayName = displayInfo.itemDescription,
      spriteName = displayInfo.spritePath,
      spriteColor = displayInfo.spriteColor,
      description = "@ui_mtx_dye_description_default",
      sourceType = sourceType or nil,
      productType = productType or nil
    },
    rewardType = eRewardTypeItemDye,
    rewardKey = dyeColor.index,
    availableProducts = dyeColor.availableProducts,
    dynamicInfoText = dyeColor.count == 0 and "@ui_do_not_own" or nil,
    dynamicInfoColor = self.UIStyle.COLOR_RED,
    disclaimerText = "@ui_mtx_disclaimer"
  }
  table.insert(rows, row)
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
    flyoutMenu:SetOpenLocation(dyeColor.entityId, flyoutMenu.PREFER_RIGHT)
    flyoutMenu:EnableFlyoutDelay(true, 0.5)
    flyoutMenu:SetFadeInTime(0.4)
    flyoutMenu:SetRowData(rows)
    flyoutMenu:DockToCursor(10, true)
  end
end
function DyePicker:RecentColorSelected(index, itemId)
  self:ColorSelected(index, itemId)
end
function DyePicker:OnDyeColorSpawned(slice, data)
  self.availableColors[data.index] = {
    color = slice,
    count = data.count
  }
  slice:SetColor(data.index)
  slice:SetCount(data.count)
  slice:SetItemId(data.itemId)
  slice:SetIsNew(data.isNew)
  slice:SetAvailableProducts(data.availableProducts, data.grantInfo)
  slice:SetCallbacks(self, self.ColorSelected, self.OnEntitlementDyeHoverStart, self.OnMarkDyeSeen)
  slice:SetHoverCallbacks(self, self.OnColorHover, self.OnColorUnhover)
  local followingEntityId = EntityId()
  for index, entry in ipairs(self.availableColors) do
    if index > data.index then
      followingEntityId = entry.color.entityId
      break
    end
  end
  local isAvailable = data.index > 0
  if isAvailable then
    UiElementBus.Event.Reparent(slice.entityId, self.Properties.AvailableList, followingEntityId)
    UiElementBus.Event.SetIsEnabled(slice.entityId, true)
  else
    UiElementBus.Event.SetIsEnabled(slice.entityId, false)
  end
  for i = 1, #self.recentColors do
    if self.recentColors[i].index == data.index then
      self.recentColors[i]:SetIsHandlingEvents(isAvailable)
      break
    end
  end
end
function DyePicker:OnColorHover(dyeColorEntity)
  if self.isVisible then
    self.callback(self.context, dyeColorEntity.index, true)
  end
end
function DyePicker:OnColorUnhover(dyeColorEntity)
  if self.isVisible then
    self.callback(self.context, self.startingIndex, true)
  end
end
function DyePicker:OnClickOut()
  self:SetVisible(false)
end
function DyePicker:IsColorEntitlement(index)
  return self.entitledDyes[index]
end
return DyePicker
