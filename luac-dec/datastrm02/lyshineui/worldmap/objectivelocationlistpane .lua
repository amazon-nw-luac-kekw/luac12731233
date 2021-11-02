local ObjectiveLocationListPane = {
  Properties = {
    ButtonClose = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    ObjectiveLocationListScrollBox = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Dropdown = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ObjectiveLocationListPane)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
function ObjectiveLocationListPane:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.Map.Connect(self.entityId, self)
  self.ButtonClose:SetCallback(self.OnCloseObjectiveLocationListPane, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_LEFT)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.ObjectiveLocationListScrollBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.ObjectiveLocationListScrollBox)
  self.section = {
    ActiveObjectives = 1,
    ReadyToTurnIn = 2,
    LocationName = 3,
    NoLocation = 4,
    Location = 5,
    MainStoryQuest = 6,
    SideQuests = 7,
    FactionMissions = 8,
    CommunityGoal = 9,
    Crafting = 10,
    World = 11
  }
  self.sections = {
    {
      headerTitle = "@objective_active",
      section = self.section.ActiveObjectives,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_ready_to_turn_in",
      section = self.section.ReadyToTurnIn,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_has_location",
      section = self.section.LocationName,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_no_location",
      section = self.section.NoLocation,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_location",
      section = self.section.Location,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_msq",
      section = self.section.MainStoryQuest,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_side_quests",
      section = self.section.SideQuests,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_faction_missions",
      section = self.section.FactionMissions,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_community_goal",
      section = self.section.CommunityGoal,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_crafting",
      section = self.section.Crafting,
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@objective_world",
      section = self.section.World,
      collapsed = false,
      data = {}
    }
  }
  self.activeSections = {}
  self.difficultyIndexToSectionMap = {
    [0] = self.section.ActiveObjectives,
    [1] = self.section.ReadyToTurnIn
  }
  self.distanceIndexToSectionMap = {
    [0] = self.section.LocationName,
    [1] = self.section.NoLocation
  }
  self.objectiveTypeIndexToSection = {
    [eObjectiveType_Objective] = self.section.SideQuests,
    [eObjectiveType_POI] = self.section.Location,
    [eObjectiveType_Crafting] = self.section.Crafting,
    [eObjectiveType_Journey] = self.section.SideQuests,
    [eObjectiveType_Mission] = self.section.FactionMissions,
    [eObjectiveType_CommunityGoal] = self.section.CommunityGoal,
    [eObjectiveType_Darkness_Minor] = self.section.Location,
    [eObjectiveType_Darkness_Major] = self.section.Location,
    [eObjectiveType_Arena] = self.section.Location,
    [eObjectiveType_Invasion] = self.section.Location,
    [eObjectiveType_DefendObject] = self.section.Location,
    [eObjectiveType_MainStoryQuest] = self.section.MainStoryQuest,
    [eObjectiveType_DynamicPOI] = self.section.Crafting
  }
  self.territoryIdIndexToSection = {
    [0] = self.section.World
  }
  local territories = MapComponentBus.Broadcast.GetTerritories()
  for index = 1, #territories do
    local territory = territories[index]
    if territory.id ~= nil then
      local territoryData = {
        headerTitle = territory.territoryName,
        section = territory.id,
        collapsed = false,
        data = {}
      }
      local numSections = CountAssociativeTable(self.section) + 1
      self.section[territoryData.section] = numSections
      self.territoryIdIndexToSection[territory.id] = self.section[territoryData.section]
      table.insert(self.sections, territoryData)
    end
  end
  self.reasonListData = {
    {
      text = "@objective_sort_distance",
      description = "",
      sortEnum = eObjectiveOrder_Distance,
      indexToSectionMap = self.distanceIndexToSectionMap,
      enum = eObjectiveOrder_Distance
    },
    {
      text = "@objective_sort_difficulty",
      description = "",
      sortEnum = eObjectiveOrder_Difficulty,
      indexToSectionMap = self.difficultyIndexToSectionMap,
      enum = eObjectiveOrder_Difficulty
    },
    {
      text = "@objective_sort_territory",
      description = "",
      sortEnum = eObjectiveOrder_Territory,
      indexToSectionMap = self.territoryIdIndexToSection,
      enum = eObjectiveOrder_Territory
    },
    {
      text = "@objective_sort_type",
      description = "",
      sortEnum = eObjectiveOrder_Type,
      indexToSectionMap = self.objectiveTypeIndexToSection,
      enum = eObjectiveOrder_Type
    }
  }
  self.currentReason = self.reasonListData[1]
  self.Dropdown:SetDropdownScreenCanvasId(self.entityId)
  self.Dropdown:SetListData(self.reasonListData)
  self.Dropdown:SetCallback("DropdownOptionSelected", self)
  self.Dropdown:SetText("@objective_sort_distance")
  self.Dropdown:SetCloseCallback(self.OnDropdownClose, self)
  self.Dropdown:SetDropdownListHeightByRows(4)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if playerEntityId then
      self:InitializeSections()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, territoryId)
    self.territoryId = territoryId
  end)
end
function ObjectiveLocationListPane:OnShowPanel(panelType)
  if not ConfigProviderEventBus.Broadcast.GetBool("javelin.objectives-enableDynamicSortingHud") then
    return
  end
  if panelType ~= self.panelTypes.ObjectiveLocationList then
    self:SetVisibility(false)
    return
  end
  self:InitializeSections()
  self:SetVisibility(true)
end
function ObjectiveLocationListPane:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function ObjectiveLocationListPane:OnDropdownClose()
end
function ObjectiveLocationListPane:DropdownOptionSelected(entityId, data)
  self.currentReason = data
  self:InitializeSections()
end
function ObjectiveLocationListPane:SortActiveTerritorySections()
  if self.currentReason.sortEnum ~= eObjectiveOrder_Territory then
    return
  end
  table.sort(self.activeSections, function(a, b)
    local aLoc = LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.sections[a].headerTitle)
    local bLoc = LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.sections[b].headerTitle)
    local currTerritoryIdToSection = self.territoryIdIndexToSection[self.territoryId]
    if currTerritoryIdToSection == nil or a ~= currTerritoryIdToSection and b ~= currTerritoryIdToSection then
      return aLoc < bLoc
    end
    local currTerrLoc = LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.sections[currTerritoryIdToSection].headerTitle)
    return aLoc == currTerrLoc
  end)
end
function ObjectiveLocationListPane:AddObjectiveIdsToSection(section, objectiveList)
  if objectiveList == nil then
    return
  end
  ClearTable(self.sections[section].data)
  for i = 1, #objectiveList do
    table.insert(self.sections[section].data, objectiveList[i])
    self:AddElementToSection(self.section[section], #self.sections[section].data - 1, 1)
  end
end
function ObjectiveLocationListPane:UpdateObjectiveList()
  local objectivesSortedBySortType = ObjectivesComponentRequestBus.Event.GetObjectivesOrdered(self.playerEntityId, self.currentReason.sortEnum)
  if objectivesSortedBySortType and 0 < #objectivesSortedBySortType then
    for i = 1, #objectivesSortedBySortType do
      local pair = objectivesSortedBySortType[i]
      if pair and pair.second and 0 < #pair.second then
        self:AddObjectiveIdsToSection(self.currentReason.indexToSectionMap[pair.first], pair.second)
      end
    end
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ObjectiveLocationListScrollBox)
end
function ObjectiveLocationListPane:InitializeSections()
  self:RefreshActiveSections()
  self:UpdateObjectiveList()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ObjectiveLocationListScrollBox)
end
function ObjectiveLocationListPane:RefreshActiveSections()
  if self.currentReason.enum == eObjectiveOrder_Distance then
    self.activeSections = {
      self.section.LocationName,
      self.section.NoLocation
    }
  elseif self.currentReason.enum == eObjectiveOrder_Difficulty then
    self.activeSections = {
      self.section.ActiveObjectives,
      self.section.ReadyToTurnIn
    }
  elseif self.currentReason.enum == eObjectiveOrder_Territory then
    self.activeSections = {
      self.section.World
    }
    local territories = MapComponentBus.Broadcast.GetTerritories()
    for index = 1, #territories do
      local territory = territories[index]
      if territory.id ~= nil then
        table.insert(self.activeSections, self.section[territory.id])
      end
    end
    self:SortActiveTerritorySections()
  elseif self.currentReason.enum == eObjectiveOrder_Type then
    self.activeSections = {
      self.section.Location,
      self.section.MainStoryQuest,
      self.section.SideQuests,
      self.section.FactionMissions,
      self.section.CommunityGoal,
      self.section.Crafting
    }
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ObjectiveLocationListScrollBox)
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.ObjectiveLocationListScrollBox, 0)
end
function ObjectiveLocationListPane:SetVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {x = -600}, {x = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.2, {opacity = 0, delay = 0.2})
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {x = 0}, {
      x = -600,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.05, {opacity = 1})
  end
end
function ObjectiveLocationListPane:IsVisible()
  return self.isVisible
end
function ObjectiveLocationListPane:OnCloseObjectiveLocationListPane()
  self:SetVisibility(false)
end
function ObjectiveLocationListPane:OnObjectiveLocationClick(objectiveId)
  local position = DynamicBus.ObjectivesLayer.Broadcast.GetObjectivePosition(objectiveId)
  if position then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.SetOpenMapCenteredOnPlayer", false)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapPosition", position)
    LyShineManagerBus.Broadcast.SetState(2477632187)
  end
end
function ObjectiveLocationListPane:GetActiveSectionIndex(section)
  for i = 1, #self.activeSections do
    if section == self.activeSections[i] then
      return i
    end
  end
  return -1
end
function ObjectiveLocationListPane:GetNumElements()
  return 0
end
function ObjectiveLocationListPane:GetNumSections()
  return #self.activeSections
end
function ObjectiveLocationListPane:GetNumElementsInSection(sectionIndex)
  if #self.activeSections == 0 then
    return 0
  end
  local sectionData = self.sections[self.activeSections[sectionIndex + 1]]
  if not sectionData or sectionData.collapsed then
    return 0
  else
    return #sectionData.data
  end
end
function ObjectiveLocationListPane:AddElementToSection(section, index, count)
  local sectionIndex = self:GetActiveSectionIndex(section)
  if sectionIndex == -1 then
    self:RefreshActiveSections()
  else
    UiDynamicScrollBoxBus.Event.InsertElementsIntoSection(self.ObjectiveLocationListScrollBox, sectionIndex - 1, index, count)
  end
end
function ObjectiveLocationListPane:OnElementInSectionBecomingVisible(entityId, sectionIndex, itemIndexInSection)
  UiElementBus.Event.SetIsEnabled(entityId, true)
  local entityTable = self.registrar:GetEntityTable(entityId)
  local data = self.sections[self.activeSections[sectionIndex + 1]].data[itemIndexInSection + 1]
  if data == nil then
    return
  end
  entityTable:SetData(data, self, self.OnObjectiveLocationClick)
end
function ObjectiveLocationListPane:OnSectionHeaderBecomingVisible(entityId, sectionIndex)
  if #self.activeSections == 0 then
    UiElementBus.Event.SetIsEnabled(entityId, false)
    return
  end
  UiElementBus.Event.SetIsEnabled(entityId, true)
  local activeSection = self.sections[self.activeSections[sectionIndex + 1]]
  if activeSection == nil then
    return
  end
  local numberOfEntries = #activeSection.data
  local entityTable = self.registrar:GetEntityTable(entityId)
  entityTable:SetTitle(self.sections[self.activeSections[sectionIndex + 1]].headerTitle)
  entityTable:SetIsBright(0 < numberOfEntries)
end
return ObjectiveLocationListPane
