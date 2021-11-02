local WarboardRankingsTable = {
  Properties = {
    FilterTab = {
      Group = {
        default = EntityId()
      },
      TabbedList = {
        default = EntityId()
      }
    },
    Tables = {
      Rankings = {
        default = EntityId()
      }
    },
    SortButtons = {
      default = {
        EntityId()
      }
    }
  },
  SORT_DESCENDING = 0,
  SORT_ASCENDING = 1,
  sortDirection = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WarboardRankingsTable)
local warboardCommon = RequireScript("LyShineUI.Warboard.WarboardCommon")
function WarboardRankingsTable:OnInit()
  BaseElement.OnInit(self)
  self.listData = {
    {
      text = "@ui_war_all",
      callback = self.SelectAllFilterTab,
      style = 2
    },
    {
      text = "@ui_war_allies",
      callback = self.SelectAlliesFilterTab,
      style = 2
    },
    {
      text = "@ui_war_enemies",
      callback = self.SelectEnemiesFilterTab,
      style = 2
    }
  }
  self.FILTER_ALL = 1
  self.FILTER_ALLIES = 2
  self.FILTER_ENEMIES = 3
  self.FilterTab.TabbedList:SetListData(self.listData, self)
  self.currentFilter = nil
  self.alliedPlayerData = {}
  self.enemyPlayerData = {}
  self.allPlayerData = {}
  self.rankingsTable = {}
  self.alliedTable = {}
  self.enemyTable = {}
  self.alliedColorLite = nil
  self.alliedColorDark = nil
  self.enemyColorLite = nil
  self.enemyColorDark = nil
  self:SetupSortButtons()
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Tables.Rankings)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Tables.Rankings)
end
function WarboardRankingsTable:SetDataSources(allied, enemy, all, alliedColor, enemyColor, stats)
  self.alliedPlayerData = allied
  self.enemyPlayerData = enemy
  self.allPlayerData = all
  if alliedColor ~= nil then
    self.alliedColor = alliedColor
  end
  if enemyColor ~= nil then
    self.enemyColor = enemyColor
  end
  if not self.currentFilter then
    self.FilterTab.TabbedList:SetUnselected()
    self.FilterTab.TabbedList:SetSelected(self.FILTER_ALL)
  else
    self.listData[self.currentFilter].callback(self)
  end
  for i = 0, #self.SortButtons do
    self.SortButtons[i]:SetText(stats[i + 1].loc)
  end
end
function WarboardRankingsTable:OnShutdown()
end
function WarboardRankingsTable:SetupSortButtons()
  for i, button in pairs(self.SortButtons) do
    button:SetCallback(self.OnSortButtonClicked, self)
    button:SetDeselected()
    button:SetDisplayType(eUiHAlign_Center)
  end
  self.sortIndex = warboardCommon.rankIndex
  self.SortButtons[self.sortIndex - 1]:SetSelectedAscending()
end
function WarboardRankingsTable:OnSortButtonClicked(sortButton)
  for index, button in pairs(self.SortButtons) do
    if button == sortButton then
      self.sortIndex = index + 1
      if button.isSelected and button.direction == button.DESCENDING then
        button:SetSelectedAscending()
        self.sortDirection = self.SORT_ASCENDING
      else
        button:SetSelectedDescending()
        self.sortDirection = self.SORT_DESCENDING
      end
    else
      button:SetDeselected()
    end
  end
  self:SortRankingsList()
end
function WarboardRankingsTable:SortRankingsList()
  local sourceData = self.allPlayerData
  if self.currentFilter == self.FILTER_ALLIES then
    sourceData = self.alliedPlayerData
  elseif self.currentFilter == self.FILTER_ENEMIES then
    sourceData = self.enemyPlayerData
  end
  table.sort(sourceData, function(a, b)
    if b.values[warboardCommon.firstStatIndex] == a.values[warboardCommon.firstStatIndex] then
      return b.playerId:GetCharacterIdString() < a.playerId:GetCharacterIdString()
    else
      return b.values[warboardCommon.firstStatIndex] < a.values[warboardCommon.firstStatIndex]
    end
  end)
  ClearTable(self.rankingsTable)
  local i = 1
  local entryColor
  for _, v in pairs(sourceData) do
    if v.allied then
      entryColor = self.alliedColor
    else
      entryColor = self.enemyColor
    end
    local playerData = {
      playerId = v.playerId,
      isConnected = v.isConnected,
      highlight = v.highlight,
      values = v.values,
      color = entryColor,
      statIndex = i
    }
    playerData.values[warboardCommon.rankIndex] = i
    table.insert(self.rankingsTable, playerData)
    i = i + 1
  end
  if self.rankingsTable[1] and type(self.rankingsTable[1].values[self.sortIndex]) == "string" then
    table.sort(self.rankingsTable, function(a, b)
      if self.sortDirection == self.SORT_ASCENDING then
        if b.values[self.sortIndex]:upper() == a.values[self.sortIndex]:upper() then
          return b.playerId:GetCharacterIdString() > a.playerId:GetCharacterIdString()
        else
          return b.values[self.sortIndex]:upper() > a.values[self.sortIndex]:upper()
        end
      elseif b.values[self.sortIndex]:upper() == a.values[self.sortIndex]:upper() then
        return b.playerId:GetCharacterIdString() < a.playerId:GetCharacterIdString()
      else
        return b.values[self.sortIndex]:upper() < a.values[self.sortIndex]:upper()
      end
    end)
  else
    table.sort(self.rankingsTable, function(a, b)
      if self.sortDirection == self.SORT_ASCENDING then
        if b.values[self.sortIndex] == a.values[self.sortIndex] then
          return b.playerId:GetCharacterIdString() > a.playerId:GetCharacterIdString()
        else
          return b.values[self.sortIndex] > a.values[self.sortIndex]
        end
      elseif b.values[self.sortIndex] == a.values[self.sortIndex] then
        return b.playerId:GetCharacterIdString() < a.playerId:GetCharacterIdString()
      else
        return b.values[self.sortIndex] < a.values[self.sortIndex]
      end
    end)
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Tables.Rankings)
end
function WarboardRankingsTable:SelectAllFilterTab()
  self:OnFilterTabSelected(self.FILTER_ALL)
end
function WarboardRankingsTable:SelectAlliesFilterTab()
  self:OnFilterTabSelected(self.FILTER_ALLIES)
end
function WarboardRankingsTable:SelectEnemiesFilterTab()
  self:OnFilterTabSelected(self.FILTER_ENEMIES)
end
function WarboardRankingsTable:OnFilterTabSelected(filterId)
  self.currentFilter = filterId
  self:SortRankingsList()
end
function WarboardRankingsTable:SetInvasionMode(enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.FilterTab.Group, not enable)
end
function WarboardRankingsTable:GetNumElements()
  local busId = UiDynamicScrollBoxDataBus.GetCurrentBusId()
  if busId == self.Properties.Tables.Rankings then
    return #self.rankingsTable
  else
    Log("WarboardRankingsTable: GetNumElements requested from unrecognized scroll box")
    return 0
  end
end
function WarboardRankingsTable:OnElementBecomingVisible(rootEntity, index)
  local function updateRankingsListItem(self, dataTable, i)
    local currentData = dataTable[i + 1]
    if currentData then
      local listItem = self.registrar:GetEntityTable(rootEntity)
      if listItem ~= nil then
        listItem:SetData(currentData)
      end
    end
  end
  local busId = UiDynamicScrollBoxElementNotificationBus.GetCurrentBusId()
  if busId == self.Properties.Tables.Rankings then
    updateRankingsListItem(self, self.rankingsTable, index)
  else
    Log("WarboardRankingsTable: OnElementBecomingVisible requested from unrecognized scroll box")
  end
end
return WarboardRankingsTable
