local TabbedListHorizontal = {
  Properties = {
    ButtonHolder = {
      default = EntityId()
    },
    LayoutCellProperties = {
      MinWidth = {default = -1},
      MinHeight = {default = -1},
      TargetWidth = {default = -1},
      TargetHeight = {default = -1},
      ExtraWidthRatio = {default = -1},
      ExtraHeightRatio = {default = -1}
    }
  },
  mSelectedTab = nil,
  mTabArray = {},
  mTabCount = 0,
  mSpawnFinsihedCallback = nil,
  mSpawnFinishedTable = nil,
  mTotalItems = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TabbedListHorizontal)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(TabbedListHorizontal)
function TabbedListHorizontal:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiSpawnerNotificationBus, self.ButtonHolder)
end
function TabbedListHorizontal:SetCallback(command, table)
  self.mSpawnFinsihedCallback = command
  self.mSpawnFinishedTable = table
end
function TabbedListHorizontal:AddTab(text, pressCallback, pressTable, tabData, slicePath, focusFirstItem, totalItems)
  local tabData = tabData or {}
  local slicePath = slicePath or "LyShineUI\\Slices\\Button"
  if totalItems then
    self.mTotalItems = totalItems
  end
  self.mTabCount = self.mTabCount + 1
  tabData.tabIndex = self.mTabCount
  tabData.pressCallback = pressCallback
  tabData.pressTable = pressTable
  tabData.text = text
  tabData.focusFirstItem = focusFirstItem
  self:SpawnSlice(self.ButtonHolder, slicePath, self.OnTabSpawned, tabData)
end
function TabbedListHorizontal:OnTabSpawned(entity, data)
  entity.tabData = data
  self.mTabArray[data.tabIndex] = entity
  entity:SetText(data.text)
  for key, value in pairs(self.LayoutCellProperties) do
    local setMethod = "Set" .. key
    if 0 <= value and UiLayoutCellBus.Event[setMethod] ~= nil then
      UiLayoutCellBus.Event[setMethod](entity.entityId, value)
    end
  end
  entity:SetCallback(self.OnTabPressed, self)
  local shouldBeFocused = data.startFocused or self.mSelectedTab == nil and data.tabIndex == 1 and data.focusFirstItem ~= false
  if shouldBeFocused then
    entity:SetIsSelected(true)
    entity:OnSelect()
  end
  entity:SetSize(self.LayoutCellProperties.TargetWidth, self.LayoutCellProperties.TargetHeight)
  if data.buttonStyle ~= nil then
    entity:SetButtonStyle(data.buttonStyle)
  end
  if data.textAlignment ~= nil then
    entity:SetTextAlignment(data.textAlignment)
  end
  if data.hintText ~= nil then
    entity:SetHint(data.hintText)
  end
  if data.hintKeybind then
    entity:SetHint(data.hintKeybind, true)
  end
  if data.iconPath ~= nil then
    entity:SetIconPath(data.iconPath)
  end
  if data.secondaryIconPath ~= nil then
    entity:SetSecondaryIconPath(data.secondaryIconPath)
  end
  if data.secondaryIconColor then
    entity:SetSecondaryIconColor(data.secondaryIconColor)
  end
  if data.tabIndex == self.mTotalItems then
    entity:SetLastIndex(true)
  end
  local isLastTabSpawned = self.mTotalItems == #self.mTabArray
  if self.mSpawnFinsihedCallback ~= nil and self.mSpawnFinishedTable ~= nil and isLastTabSpawned and type(self.mSpawnFinsihedCallback) == "function" then
    self.mSpawnFinsihedCallback(self.mSpawnFinishedTable, self)
  end
end
function TabbedListHorizontal:GetTab(index)
  if self.mTabArray[index] ~= nil then
    return self.mTabArray[index]
  end
  return nil
end
function TabbedListHorizontal:GetTabData(index)
  if self.mTabArray[index] ~= nil then
    return self.mTabArray[index].tabData
  end
  return nil
end
function TabbedListHorizontal:SetSecondaryIconPath(index, iconPath)
  local tab = self:GetTab(index)
  if tab then
    tab:SetSecondaryIconPath(iconPath)
  end
end
function TabbedListHorizontal:SetSecondaryIconColor(index, color)
  local tab = self:GetTab(index)
  if tab then
    tab:SetSecondaryIconColor(color)
  end
end
function TabbedListHorizontal:SetSecondaryIconValue(index, value)
  local tab = self:GetTab(index)
  if tab then
    tab:SetSecondaryIconValue(value)
  end
end
function TabbedListHorizontal:SetSelectedTab(index)
  local tab = self:GetTab(index)
  if self.mSelectedTab ~= tab then
    if self.mSelectedTab ~= nil then
      self.mSelectedTab:SetIsSelected(false)
      self.mSelectedTab:OnUnfocus()
    end
    self.mSelectedTab = tab
    self.mSelectedTab:SetIsSelected(true)
    self.mSelectedTab:OnSelect()
  end
end
function TabbedListHorizontal:GetSelectedTab()
  if self.mSelectedTab ~= nil then
    return self.mSelectedTab
  end
  return nil
end
function TabbedListHorizontal:GetSelectedTabData()
  if self.mSelectedTab ~= nil then
    return self.mSelectedTab.tabData
  end
  return nil
end
function TabbedListHorizontal:GetTabCount()
  return self.mTabCount
end
function TabbedListHorizontal:UnfocusSelectedTab()
  if self.mSelectedTab ~= nil then
    self.mSelectedTab:SetIsSelected(false)
    self.mSelectedTab:OnUnfocus()
    self.mSelectedTab = nil
  end
end
function TabbedListHorizontal:OnTabPressed(tab)
  if self.mSelectedTab ~= tab then
    self:SetSelectedTab(tab.tabData.tabIndex)
    self.mSelectedTab:ExecuteCallback(self.mSelectedTab.tabData.pressTable, self.mSelectedTab.tabData.pressCallback)
  end
end
return TabbedListHorizontal
