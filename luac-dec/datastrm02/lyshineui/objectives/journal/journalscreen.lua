local JournalScreen = {
  Properties = {
    PrimaryTabbedList = {
      default = EntityId()
    },
    DocumentsTab = {
      default = EntityId()
    },
    ObjectivesTab = {
      default = EntityId()
    }
  },
  activeTabTable = nil,
  openToLoreId = nil,
  closeInteractionWhenComplete = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(JournalScreen)
function JournalScreen:OnInit()
  BaseScreen.OnInit(self)
  local enableJournal = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-journal")
  if enableJournal then
    self.dataLayer:RegisterOpenEvent("Objectives", self.canvasId)
    self:BusConnect(CryActionNotificationsBus, "toggleJournalComponent")
  end
  self:BusConnect(LoreReaderNotificationsBus, self.canvasId)
  self.primaryTabsData = {
    {
      text = "@objective_objectives",
      screen = "Objectives",
      callback = self.OnPrimaryTabSelected,
      width = 338,
      height = 70,
      glowOffsetWidth = 222
    },
    {
      text = "@inv_loreItems",
      screen = "Documents",
      callback = self.OnPrimaryTabSelected,
      width = 338,
      height = 70,
      glowOffsetWidth = 222
    }
  }
  self.screenNamesToIndex = {}
  for i = 1, #self.primaryTabsData do
    local currentTab = self.primaryTabsData[i]
    self.screenNamesToIndex[currentTab.screen] = i
  end
  self.PrimaryTabbedList:SetListData(self.primaryTabsData, self)
  self.objectivesPrimaryTab = self.PrimaryTabbedList:GetIndex(self.screenNamesToIndex.Objectives)
  self.documentsPrimaryTab = self.PrimaryTabbedList:GetIndex(self.screenNamesToIndex.Documents)
  self.ObjectivesTab:SetActive(false)
  self.DocumentsTab:SetActive(false)
  DynamicBus.JournalScreen.Connect(self.entityId, self)
end
function JournalScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.JournalScreen.Disconnect(self.entityId, self)
end
function JournalScreen:OnCryAction(actionName)
  self.openToLoreId = nil
  LyShineManagerBus.Broadcast.ToggleState(1823500652)
end
function JournalScreen:OnShowLoreReader(loreId)
  self.openToLoreId = loreId
  LyShineManagerBus.Broadcast.SetState(1823500652)
end
function JournalScreen:OnAddLoreToJournal(loreId)
  self.DocumentsTab:OnAddToJournal(loreId)
end
function JournalScreen:OpenToObjectiveId(objectiveId)
  self.openToLoreId = nil
  LyShineManagerBus.Broadcast.SetState(1823500652)
  self:SetTabVisible(self.ObjectivesTab)
  self.ObjectivesTab:FocusSpecificObjectiveId(objectiveId)
end
function JournalScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if toState == 1823500652 then
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    JavelinCameraRequestBus.Broadcast.SetDepthOfField(self.UIStyle.BLUR_DEPTH_OF_FIELD, self.UIStyle.BLUR_AMOUNT, self.UIStyle.BLUR_NEAR_DISTANCE, self.UIStyle.BLUR_NEAR_SCALE, self.UIStyle.RANGE_DEPTH_OF_FIELD)
    self.DocumentsTab:SetStartingPage(self.openToLoreId)
    self.closeInteractionWhenComplete = self.openToLoreId ~= nil
    if self.openToLoreId ~= nil then
      self.PrimaryTabbedList:SetSelected(self.screenNamesToIndex.Documents)
    elseif self.activeTabTable == nil then
      self.PrimaryTabbedList:SetSelected(self.screenNamesToIndex.Objectives)
      self.DocumentsTab:UpdateLockedStatus(true)
    elseif self.activeTabTable == self.ObjectivesTab then
      self.ObjectivesTab:RefreshObjectiveList()
    end
    self.audioHelper:PlaySound(self.audioHelper.Lore_JournalOpen)
    self.openToLoreId = nil
    self.isScreenActive = true
  else
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function JournalScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.isScreenActive then
    self.isScreenActive = false
    JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    if self.closeInteractionWhenComplete then
      LoreReaderRequestsBus.Broadcast.LoreReaderClosed()
    end
    self.audioHelper:PlaySound(self.audioHelper.Lore_JournalClose)
  end
  if toState == 2702338936 or toLevel == -1 then
    self.PrimaryTabbedList:SetUnselected()
    self:SetTabVisible(nil)
  end
end
function JournalScreen:SetTabVisible(tabTable)
  if self.activeTabTable then
    if self.activeTabTable == tabTable then
      if tabTable.Refresh then
        tabTable:Refresh()
      end
      return
    end
    if self.activeTabTable.SetActive then
      self.activeTabTable:SetActive(false)
    end
  end
  self.activeTabTable = tabTable
  if self.activeTabTable and self.activeTabTable.SetActive then
    self.activeTabTable:SetActive(true)
  end
end
function JournalScreen:OnPrimaryTabSelected(entityId)
  local panes = {
    self.ObjectivesTab,
    self.DocumentsTab
  }
  local tabIndex = entityId:GetIndex()
  self:SetTabVisible(panes[tabIndex])
end
function JournalScreen:OpenMap(data)
  LyShineManagerBus.Broadcast.SetState(2477632187)
end
return JournalScreen
