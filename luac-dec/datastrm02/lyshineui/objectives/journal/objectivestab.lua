local ObjectivesTab = {
  Properties = {
    TabbedList = {
      default = EntityId()
    },
    ObjectivesScrollBox = {
      default = EntityId()
    },
    ObjectivesScrollBoxContent = {
      default = EntityId()
    },
    LocationTitleText = {
      default = EntityId()
    },
    LocationList = {
      default = EntityId()
    },
    MSQTitleText = {
      default = EntityId()
    },
    MSQList = {
      default = EntityId()
    },
    MSQToggle = {
      default = EntityId()
    },
    JourneyTitleText = {
      default = EntityId()
    },
    JourneyList = {
      default = EntityId()
    },
    JourneyToggle = {
      default = EntityId()
    },
    MissionTitleText = {
      default = EntityId()
    },
    MissionList = {
      default = EntityId()
    },
    MissionToggle = {
      default = EntityId()
    },
    CommunityTitleText = {
      default = EntityId()
    },
    CommunityList = {
      default = EntityId()
    },
    CommunityToggle = {
      default = EntityId()
    },
    RecipeTitleText = {
      default = EntityId()
    },
    RecipeList = {
      default = EntityId()
    },
    RecipeToggle = {
      default = EntityId()
    }
  },
  objectiveSlices = {},
  SCROLL_PERCENTAGE_TO_HIGHLIGHT_TAB = 0.1,
  TAB_CLICK_SOUND = "Guild_TabSelected",
  MAX_PINNED_OBJECTIVES = 6,
  DEBUG = false,
  scrollStep = 150
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ObjectivesTab)
function ObjectivesTab:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.autoPinToggleData = {
    {
      entity = self.MSQToggle,
      enum = eObjectiveType_MainStoryQuest,
      tooltipText = "@ui_autopinobjectivesMain_desc"
    },
    {
      entity = self.JourneyToggle,
      enum = eObjectiveType_Objective,
      tooltipText = "@ui_autopinobjectivesSide_desc"
    },
    {
      entity = self.MissionToggle,
      enum = eObjectiveType_Mission,
      tooltipText = "@ui_autopinobjectivesFaction_desc"
    },
    {
      entity = self.CommunityToggle,
      enum = eObjectiveType_CommunityGoal,
      tooltipText = "@ui_autopinobjectivesComm_desc"
    },
    {
      entity = self.RecipeToggle,
      enum = eObjectiveType_Crafting,
      tooltipText = "@ui_autopinobjectivesCrafting_desc"
    }
  }
  for _, toggleData in ipairs(self.autoPinToggleData) do
    local toggleTable = toggleData.entity
    toggleTable:SetCallback(function(self)
      DynamicBus.Options.Broadcast.SetObjectiveAutoPin(toggleData.enum, false)
      OptionsDataBus.Broadcast.SerializeOptions()
    end, function(self)
      DynamicBus.Options.Broadcast.SetObjectiveAutoPin(toggleData.enum, true)
      OptionsDataBus.Broadcast.SerializeOptions()
    end, self)
    toggleTable:SetText("@ui_no", "@ui_yes")
    toggleTable:SetHeight(32)
    toggleTable:SetWidth(100)
    toggleTable:SetTooltipButton1(toggleData.tooltipText)
    toggleTable:SetTooltipButton2(toggleData.tooltipText)
    local dataPath = string.format("Hud.LocalPlayer.Options.Misc.EnableAutoPinningObjectives.%s", toggleData.enum)
    local initialVal = self.dataLayer:GetDataFromNode(dataPath) or 0
    toggleTable:InitToggleState(initialVal)
    toggleTable:SetDataNode(dataPath)
  end
  self.dataLayer:OnChange(self, "javelin.enable-auto-pin-options", function(self, enableAutoPinDataNode)
    if enableAutoPinDataNode then
      local isEnabled = enableAutoPinDataNode:GetData()
      for _, toggleData in ipairs(self.autoPinToggleData) do
        UiElementBus.Event.SetIsEnabled(toggleData.entity.entityId, isEnabled)
      end
    end
  end)
  self.tabData = {
    {
      text = "@objective_location",
      section = "Location",
      tooltipText = "@objective_location_desc",
      callback = self.OnTypeTabPressed,
      style = 2,
      height = 45
    },
    {
      text = "@objective_msq",
      section = "MSQ",
      tooltipText = "@objective_msq_desc",
      callback = self.OnTypeTabPressed,
      style = 2,
      height = 45
    },
    {
      text = "@objective_journey",
      section = "Journey",
      tooltipText = "@objective_journey_desc",
      callback = self.OnTypeTabPressed,
      style = 2,
      height = 45
    },
    {
      text = "@objective_mission",
      section = "Mission",
      tooltipText = "@objective_mission_desc",
      callback = self.OnTypeTabPressed,
      style = 2,
      height = 45
    },
    {
      text = "@objective_townproject",
      section = "Community",
      tooltipText = "@objective_townproject_desc",
      callback = self.OnTypeTabPressed,
      style = 2,
      height = 45
    },
    {
      text = "@objective_recipes",
      section = "Recipe",
      tooltipText = "@objective_recipes_desc",
      callback = self.OnTypeTabPressed,
      style = 2,
      height = 45
    }
  }
  self.TabbedList:SetListData(self.tabData, self)
  self.sectionNamesToIndex = {}
  for i = 1, #self.tabData do
    local currentTab = self.tabData[i]
    self.sectionNamesToIndex[currentTab.section] = i
  end
  self.locationTab = self.TabbedList:GetIndex(self.sectionNamesToIndex.Location)
  self.msqTab = self.TabbedList:GetIndex(self.sectionNamesToIndex.MSQ)
  self.journeyTab = self.TabbedList:GetIndex(self.sectionNamesToIndex.Journey)
  self.missionTab = self.TabbedList:GetIndex(self.sectionNamesToIndex.Mission)
  self.communityTab = self.TabbedList:GetIndex(self.sectionNamesToIndex.Community)
  self.recipeTab = self.TabbedList:GetIndex(self.sectionNamesToIndex.Recipe)
  self.listsByType = {
    [eObjectiveType_POI] = self.Properties.LocationList,
    [eObjectiveType_Darkness_Minor] = self.Properties.LocationList,
    [eObjectiveType_Darkness_Major] = self.Properties.LocationList,
    [eObjectiveType_Arena] = self.Properties.LocationList,
    [eObjectiveType_Dungeon] = self.Properties.LocationList,
    [eObjectiveType_MainStoryQuest] = self.Properties.MSQList,
    [eObjectiveType_Journey] = self.Properties.JourneyList,
    [eObjectiveType_Quest] = self.Properties.JourneyList,
    [eObjectiveType_Mission] = self.Properties.MissionList,
    [eObjectiveType_CommunityGoal] = self.Properties.CommunityList,
    [eObjectiveType_Crafting] = self.Properties.RecipeList,
    [eObjectiveType_DefendObject] = self.Properties.LocationList,
    [eObjectiveType_DynamicPOI] = self.Properties.LocationList
  }
  self.tabTableToList = {
    [self.locationTab] = self.Properties.LocationList,
    [self.msqTab] = self.Properties.MSQList,
    [self.journeyTab] = self.Properties.JourneyList,
    [self.missionTab] = self.Properties.MissionList,
    [self.communityTab] = self.Properties.CommunityList,
    [self.recipeTab] = self.Properties.RecipeList
  }
  self.listMap = {
    [self.Properties.LocationList] = {
      tabTable = self.locationTab,
      title = self.Properties.LocationTitleText
    },
    [self.Properties.MSQList] = {
      tabTable = self.msqTab,
      title = self.Properties.MSQTitleText
    },
    [self.Properties.JourneyList] = {
      tabTable = self.journeyTab,
      title = self.Properties.JourneyTitleText
    },
    [self.Properties.MissionList] = {
      tabTable = self.missionTab,
      title = self.Properties.MissionTitleText
    },
    [self.Properties.CommunityList] = {
      tabTable = self.communityTab,
      title = self.Properties.CommunityTitleText
    },
    [self.Properties.RecipeList] = {
      tabTable = self.recipeTab,
      title = self.Properties.RecipeTitleText
    }
  }
  self.scrollBoxHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ObjectivesScrollBox)
  SetTextStyle(self.Properties.LocationTitleText, self.UIStyle.FONT_STYLE_OBJECTIVE_HEADER)
  SetTextStyle(self.Properties.MSQTitleText, self.UIStyle.FONT_STYLE_OBJECTIVE_HEADER)
  SetTextStyle(self.Properties.JourneyTitleText, self.UIStyle.FONT_STYLE_OBJECTIVE_HEADER)
  SetTextStyle(self.Properties.MissionTitleText, self.UIStyle.FONT_STYLE_OBJECTIVE_HEADER)
  SetTextStyle(self.Properties.CommunityTitleText, self.UIStyle.FONT_STYLE_OBJECTIVE_HEADER)
  SetTextStyle(self.Properties.RecipeTitleText, self.UIStyle.FONT_STYLE_OBJECTIVE_HEADER)
  self.TabbedList:SetSelected(self.sectionNamesToIndex.Location)
  self.activeTab = self.locationTab
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", self.OnObjectiveEntityIdChanged)
end
function ObjectivesTab:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
end
function ObjectivesTab:OnPinnedObjectiveChanged()
  for listEntityId, listMapData in pairs(self.listMap) do
    local childList = UiElementBus.Event.GetChildren(listEntityId)
    for i = 1, #childList do
      local objectiveTable = self.registrar:GetEntityTable(childList[i])
      objectiveTable:UpdatePinStatus()
    end
  end
end
function ObjectivesTab:RefreshObjectiveList()
  self.objectiveSlices = {}
  local objectiveLists = {}
  if self.objectiveEntityId == nil then
    self.objectiveEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ObjectiveEntityId")
  end
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local objectives = ObjectivesComponentRequestBus.Event.GetObjectives(playerEntityId)
  for i = 1, #objectives do
    self:DebugLogObjectiveById(objectives[i])
    local objectiveType = ObjectiveRequestBus.Event.GetType(objectives[i])
    if self.listsByType[objectiveType] then
      local listId = self.listsByType[objectiveType]
      if not objectiveLists[listId] then
        objectiveLists[listId] = {}
      end
      local isActive = true
      if objectiveType == eObjectiveType_DynamicPOI then
        isActive = ObjectiveRequestBus.Event.IsDynamicPoiObjectiveActive(objectives[i])
      end
      if isActive then
        table.insert(objectiveLists[listId], objectives[i])
      end
    else
      Debug.Log("[ObjectivesTab:RefreshObjectiveList] Error: Tried to handle objective of unknown type! Type=" .. tostring(objectiveType))
      if objectiveType == nil then
        Debug.Log(debug.traceback())
      end
    end
  end
  local isInOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(rootEntityId, 2444859928)
  local tooltip = isInOutpostRush and "@ui_pinning_disabled_while_in_or" or ""
  for listEntityId, listMapData in pairs(self.listMap) do
    local objectiveList = objectiveLists[listEntityId] or {}
    UiDynamicLayoutBus.Event.SetNumChildElements(listEntityId, #objectiveList)
    local childList = UiElementBus.Event.GetChildren(listEntityId)
    self.ScriptedEntityTweener:Play(self.listMap[listEntityId].title, 0.3, {
      textColor = 0 < #childList and self.UIStyle.COLOR_TAN_HEADER_SECONDARY or self.UIStyle.COLOR_TAN_DARK
    })
    for i = 1, #childList do
      local objectiveTable = self.registrar:GetEntityTable(childList[i])
      objectiveTable:SetObjectiveId(objectiveList[i])
      objectiveTable:SetPinnedCallback(self, self.OnPinnedObjectiveChanged)
      local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveList[i])
      if objectiveType == eObjectiveType_Dungeon then
        objectiveTable:SetPinningBlocked(true, "@ui_pinning_disabled_expeditions")
      else
        objectiveTable:SetPinningBlocked(isInOutpostRush, tooltip)
      end
      table.insert(self.objectiveSlices, objectiveTable)
    end
    self.listMap[listEntityId].tabTable:SetIconValue(#childList)
  end
  UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
  local canScroll = UiScrollBoxBus.Event.HasVerticalContentToScroll(self.Properties.ObjectivesScrollBox)
  if not canScroll then
    self.TabbedList:SetUnselected()
  end
  for _, listMapData in pairs(self.listMap) do
    UiInteractableBus.Event.SetIsHandlingEvents(listMapData.tabTable.entityId, canScroll)
  end
  self:UpdatePinButtons()
  self:RefreshIcons()
  self.canScroll = canScroll
  if self.canScroll then
    local contentHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ObjectivesScrollBoxContent)
    local scrollHeight = contentHeight - self.scrollBoxHeight
    local stepSize = 0.1
    if 0 < scrollHeight then
      local stepFraction = Math.Clamp(self.scrollStep / scrollHeight, 0, 1)
      stepSize = stepFraction * scrollHeight
    end
    UiScrollBarMouseWheelBus.Event.SetWheelStepValue(self.Properties.ObjectivesScrollBox, stepSize)
  end
end
function ObjectivesTab:EnableTimers(enable)
  for objectiveType, listEntityId in pairs(self.listsByType) do
    local childList = UiElementBus.Event.GetChildren(listEntityId)
    for i = 1, #childList do
      local objectiveTable = self.registrar:GetEntityTable(childList[i])
      objectiveTable:EnableTimer(enable)
    end
  end
end
function ObjectivesTab:SetActiveTypeTab(tabTable, onlyVisual)
  if self.activeTab == tabTable or tabTable == nil then
    return
  end
  if self.activeTab ~= nil then
    self.TabbedList:SetUnselected()
  end
  self.activeTab = tabTable
  if self.canScroll then
    self.TabbedList:SetSelected(self.activeTab:GetIndex(), onlyVisual)
  end
end
function ObjectivesTab:SetActive(active, callback)
  local animTime = 0.3
  local lineInTime = 1.2
  local endingOpacity = 1
  self.isActive = active
  if active then
    self:RefreshObjectiveList()
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, self.objectiveEntityId)
  else
    endingOpacity = 0
    self:BusDisconnect(self.objectivesComponentBusHandler)
  end
  self:EnableTimers(self.isActive)
  self.ScriptedEntityTweener:Play(self.entityId, animTime, {
    opacity = endingOpacity,
    onComplete = function()
      if not active then
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
      if callback ~= nil and type(callback) == "function" then
        callback()
      end
    end
  })
  UiScrollBoxBus.Event.SetScrollOffset(self.Properties.ObjectivesScrollBox, Vector2(0, 0))
end
function ObjectivesTab:OnTypeTabPressed(entity)
  local listId = self.tabTableToList[entity]
  local headerEntityId = self.listMap[listId].title
  local titleOffset = GetOffsetFrom(headerEntityId, self.Properties.ObjectivesScrollBoxContent).y
  local offsetModifier = 48
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.ObjectivesScrollBox, titleOffset * -1 + offsetModifier)
end
function ObjectivesTab:OnObjectiveEntityIdChanged(objectiveEntityId)
  if objectiveEntityId == nil or objectiveEntityId == self.objectiveEntityId then
    return
  end
  self.objectiveEntityId = objectiveEntityId
  self:BusDisconnect(self.objectivesComponentBusHandler)
  self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, self.objectiveEntityId)
  if self.isActive then
    self:RefreshObjectiveList()
  end
end
function ObjectivesTab:OnObjectiveAdded()
  if self.isActive then
    self:RefreshObjectiveList()
  end
end
function ObjectivesTab:OnObjectiveRemoved()
  if self.isActive then
    self:RefreshObjectiveList()
  end
end
function ObjectivesTab:OnObjectiveSortingChanged()
  if self.isActive then
    self:UpdatePinButtons()
    self:RefreshIcons()
  end
end
function ObjectivesTab:UpdatePinButtons()
  local pinnedObjectiveList = ObjectivesComponentRequestBus.Event.GetTrackedObjectives(self.objectiveEntityId)
  for _, objectiveSlice in pairs(self.objectiveSlices) do
    objectiveSlice:EnablePinButton(true, nil)
  end
end
function ObjectivesTab:RefreshIcons()
  for _, objectiveSlice in pairs(self.objectiveSlices) do
    objectiveSlice:RefreshObjectiveIconAndTextColor()
  end
end
function ObjectivesTab:OnScrollChange()
  local tabToActivate = self.listMap[self.Properties.MSQList].tabTable
  local listOrder = {
    self.Properties.LocationList,
    self.Properties.MSQList,
    self.Properties.JourneyList,
    self.Properties.MissionList,
    self.Properties.CommunityList,
    self.Properties.RecipeList
  }
  for _, listId in ipairs(listOrder) do
    local listMapData = self.listMap[listId]
    local currentOffset = GetOffsetFrom(listMapData.title, self.Properties.ObjectivesScrollBox).y
    local scrollPercent = currentOffset / self.scrollBoxHeight
    if scrollPercent < self.SCROLL_PERCENTAGE_TO_HIGHLIGHT_TAB then
      tabToActivate = listMapData.tabTable
    else
      break
    end
  end
  self:SetActiveTypeTab(tabToActivate, true)
end
function ObjectivesTab:FocusSpecificObjectiveId(objectiveId)
  local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveId)
  local objectiveList = self.listsByType[objectiveType]
  local objectiveEntityId
  local childList = UiElementBus.Event.GetChildren(objectiveList)
  for i = 1, #childList do
    local childEntityId = childList[i]
    local objectiveTable = self.registrar:GetEntityTable(childEntityId)
    if objectiveTable.objectiveId == objectiveId then
      objectiveEntityId = childEntityId
      break
    end
  end
  local height = UiTransform2dBus.Event.GetLocalHeight(objectiveEntityId)
  local scrollOffset = GetOffsetFrom(objectiveEntityId, self.Properties.ObjectivesScrollBoxContent).y
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.ObjectivesScrollBox, scrollOffset * -1 + height)
end
function ObjectivesTab:DebugLogObjectiveById(objectiveId)
  if not self.DEBUG then
    return
  end
  local objective = {
    title = ObjectiveRequestBus.Event.GetTitle(objectiveId),
    description = ObjectiveRequestBus.Event.GetDescription(objectiveId),
    numRewards = ObjectiveRequestBus.Event.GetRewardCount(objectiveId),
    taskIds = ObjectiveRequestBus.Event.GetTasks(objectiveId),
    tasks = {},
    type = ObjectiveRequestBus.Event.GetType(objectiveId)
  }
  if objective.taskIds ~= nil then
    for i = 1, #objective.taskIds do
      local task = {
        description = ObjectiveTaskRequestBus.Event.GetDescription(objective.taskIds[i]),
        itemDescriptor = ObjectiveTaskRequestBus.Event.GetUIData(objective.taskIds[i], "ItemDescriptor")
      }
      table.insert(objective.tasks, task)
    end
  end
  Debug.Log("[DEBUG] Objective - " .. tostring(objective.title))
  Debug.Log("[DEBUG] \t" .. tostring(objective.description))
  Debug.Log("[DEBUG]")
  Debug.Log("[DEBUG] \tRewards: " .. tostring(objective.numRewards))
  Debug.Log("[DEBUG] \t# Tasks: " .. tostring(#objective.tasks))
  for i = 1, #objective.tasks do
    Debug.Log("[DEBUG] \t\t" .. tostring(objective.tasks[i].description))
    if objective.tasks[i].itemDescriptor then
      Debug.Log("[DEBUG] \t\t\t" .. tostring(objective.tasks[i].itemDescriptor:GetItemKey()))
    end
  end
  Debug.Log("[DEBUG] \tType: " .. tostring(objective.type))
end
return ObjectivesTab
