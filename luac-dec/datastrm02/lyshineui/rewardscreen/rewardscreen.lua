local RewardScreen = {
  Properties = {
    SiegePanelContainer = {
      default = EntityId()
    },
    PrevButton = {
      default = EntityId()
    },
    NextButton = {
      default = EntityId()
    },
    ExitButton = {
      default = EntityId()
    },
    WinLossPanel = {
      default = EntityId()
    }
  },
  PANEL_TYPE_SIEGE = 0,
  PANEL_TYPE_OUTPOST_RUSH = 1,
  PANEL_TYPE_DUNGEON = 2,
  panels = {}
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(RewardScreen)
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function RewardScreen:OnInit()
  BaseScreen.OnInit(self)
  DynamicBus.RewardScreen.Connect(self.entityId, self)
  self:BusConnect(GroupsUINotificationBus)
  self.panelTypes = {
    {
      panelType = self.PANEL_TYPE_SIEGE,
      container = self.Properties.SiegePanelContainer
    },
    {
      panelType = self.PANEL_TYPE_OUTPOST_RUSH,
      container = self.Properties.SiegePanelContainer
    },
    {
      panelType = self.PANEL_TYPE_DUNGEON,
      container = self.Properties.SiegePanelContainer
    }
  }
  self.PrevButton:SetText("@ui_siege_reward_back")
  self.PrevButton:SetCallback(self.OnPrevPanel, self)
  self.NextButton:SetText("@ui_siege_reward_skip")
  self.NextButton:SetButtonStyle(self.NextButton.BUTTON_STYLE_CTA)
  self.NextButton:SetCallback(self.OnNextPanel, self)
  self.ExitButton:SetText("@ui_continue")
  self.ExitButton:SetButtonStyle(self.ExitButton.BUTTON_STYLE_CTA)
  self.ExitButton:SetCallback(self.OnLeave, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.raidId = raidId
    if (not raidId or not raidId:IsValid()) and LyShineManagerBus.Broadcast.IsInState(849925872) then
      LyShineManagerBus.Broadcast.ExitState(849925872)
    end
  end)
  SlashCommands:RegisterSlashCommand("reward", function(args)
    local isWin = args[2] and string.find(args[2], "w") ~= nil or false
    local isAttacker = args[2] and string.find(args[2], "a") ~= nil or false
    timingUtils:Delay(0.1, self, function()
      local data = {
        panelType = self.PANEL_TYPE_SIEGE,
        isAttacker = isAttacker,
        isWin = isWin
      }
      self:ShowRewardScreen(data)
    end)
  end)
end
function RewardScreen:OnShutdown()
  DynamicBus.RewardScreen.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
end
function RewardScreen:ShowRewardScreen(data)
  local container
  for _, typeData in ipairs(self.panelTypes) do
    local matchesType = typeData.panelType == data.panelType
    if container ~= typeData.container then
      UiElementBus.Event.SetIsEnabled(typeData.container, matchesType)
    end
    if matchesType then
      container = typeData.container
    end
  end
  if not container then
    Log("[RewardScreen] Error: data is not associated with any panels")
    return
  end
  ClearTable(self.panels)
  local children = UiElementBus.Event.GetChildren(container)
  self.numPanels = #children
  for i = 1, self.numPanels do
    local entityId = children[i]
    local entityTable = self.registrar:GetEntityTable(entityId)
    table.insert(self.panels, entityTable)
    UiElementBus.Event.SetIsEnabled(entityId, i == 1)
  end
  self:SetupPanelData(data)
  self.currentPanelIndex = 1
  self.hasSeenLastPanel = self.numPanels == 1
  UiElementBus.Event.SetIsEnabled(self.Properties.PrevButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.NextButton, self.numPanels > 1)
  LyShineManagerBus.Broadcast.SetState(849925872)
end
function RewardScreen:SetupPanelData(data)
  local titleText, reasonText, milestoneText
  local isDungeon = false
  if data.panelType == self.PANEL_TYPE_SIEGE then
    if data.isWin then
      titleText = "@ui_siege_win"
      reasonText = data.isAttacker and "@ui_siege_winreason_capture" or "@ui_siege_winreason_defend"
    else
      titleText = "@ui_siege_loss"
      if not data.isInvasion then
        reasonText = data.isAttacker and "@ui_siege_losereason_defend" or "@ui_siege_losereason_capture"
      else
        reasonText = "@ui_siege_losereason_invasion"
      end
    end
  elseif data.panelType == self.PANEL_TYPE_OUTPOST_RUSH then
    if data.isDraw then
      titleText = "@ui_siege_draw"
      reasonText = ""
    else
      if data.isWin then
        titleText = "@ui_siege_win"
      else
        titleText = "@ui_siege_loss"
      end
      local teamText = data.isWin and "@ui_outpost_rush_blue_team" or "@ui_outpost_rush_red_team"
      reasonText = GetLocalizedReplacementText("@ui_outpost_rush_won_condition", {
        team = teamText,
        score = data.score
      })
    end
  elseif data.panelType == self.PANEL_TYPE_DUNGEON then
    if data.isWin then
      titleText = "@ui_siege_win"
      reasonText = "@dungeon_completed"
    end
    isDungeon = true
  end
  local winLossPanel = self.panels[1]
  winLossPanel:SetRewardData(titleText, reasonText, milestoneText, data.isInvasion, isDungeon, self.resolutionEndPoint, self.Properties.ExitButton)
end
function RewardScreen:SetRewardScreenPanel(newPanelIndex)
  self.panels[self.currentPanelIndex]:SetRewardPanelVisible(false)
  self.panels[newPanelIndex]:SetRewardPanelVisible(true)
  if newPanelIndex == self.numPanels then
    self.hasSeenLastPanel = true
  end
  self.prevEnabled = self.hasSeenLastPanel and 1 < newPanelIndex
  self.nextEnabled = newPanelIndex < self.numPanels
  self.exitEnabled = newPanelIndex == self.numPanels
  UiElementBus.Event.SetIsEnabled(self.Properties.PrevButton, self.prevEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.NextButton, self.nextEnabled)
  if self.numPanels > 1 then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ExitButton, 180)
  end
  self.currentPanelIndex = newPanelIndex
end
function RewardScreen:OnSiegeWarfareStarted(warId)
  self.WinLossPanel:ClearRewards()
end
function RewardScreen:OnSiegeWarfareEnded(isWin, resolutionPhaseEndTimePoint)
  if not self.raidId or not self.raidId:IsValid() then
    return
  end
  local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(self.raidId)
  if warDetails:IsValid() then
    local isAttacker = warDetails:IsAttackingRaid(self.raidId)
    local guildId = isAttacker and warDetails:GetAttackerGuildId() or warDetails:GetDefenderGuildId()
    local isInvasion = not warDetails:GetAttackerGuildId():IsValid()
    local data = {
      guildId = guildId,
      panelType = self.PANEL_TYPE_SIEGE,
      isAttacker = isAttacker,
      isInvasion = isInvasion,
      isWin = isWin
    }
    self.resolutionEndPoint = resolutionPhaseEndTimePoint
    self:ShowRewardScreen(data)
  end
end
function RewardScreen:OnNextPanel()
  if self.currentPanelIndex < self.numPanels then
    self:SetRewardScreenPanel(self.currentPanelIndex + 1)
  end
end
function RewardScreen:OnPrevPanel()
  if self.currentPanelIndex > 1 then
    self:SetRewardScreenPanel(self.currentPanelIndex - 1)
  end
end
function RewardScreen:OnLeave()
  LyShineManagerBus.Broadcast.ExitState(849925872)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.siege.enable-warboard") then
    LyShineManagerBus.Broadcast.SetState(921202721)
  end
end
function RewardScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if not self.isDungeonVictory then
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    JavelinCameraRequestBus.Broadcast.SetDepthOfField(self.UIStyle.BLUR_DEPTH_OF_FIELD, self.UIStyle.BLUR_AMOUNT, self.UIStyle.BLUR_NEAR_DISTANCE, self.UIStyle.BLUR_NEAR_SCALE, self.UIStyle.RANGE_DEPTH_OF_FIELD)
  end
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
end
function RewardScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
  if not ConfigProviderEventBus.Broadcast.GetBool("javelin.siege.enable-warboard") then
    GroupsRequestBus.Broadcast.RequestLeaveGroup()
  end
  self.WinLossPanel:Reset()
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function RewardScreen:OnOutpostRushMatchEnded(orData)
  local data = {
    panelType = self.PANEL_TYPE_OUTPOST_RUSH,
    isWin = orData.playerWin,
    isDraw = orData.isDraw,
    isInvasion = false,
    score = orData.playerWin and orData.ownTeamScore or orData.enemyTeamScore
  }
  self.resolutionEndPoint = orData.cleanupTimepoint
  self:ShowRewardScreen(data)
end
function RewardScreen:OnDungeonCompletion()
  local data = {
    panelType = self.PANEL_TYPE_DUNGEON,
    isWin = true
  }
  self.isDungeonVictory = true
  self:ShowRewardScreen(data)
end
function RewardScreen:OnEscapeKeyPressed()
  local isPopupEnabled = UiElementBus.Event.IsEnabled(self.Properties.WinLossPanel)
  if isPopupEnabled then
    self.WinLossPanel:ContinueToWarboard()
    return
  else
    LyShineManagerBus.Broadcast.SetState(2702338936)
  end
end
return RewardScreen
