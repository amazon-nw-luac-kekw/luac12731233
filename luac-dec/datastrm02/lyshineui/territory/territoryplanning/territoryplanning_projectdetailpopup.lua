local TerritoryPlanning_ProjectDetailPopup = {
  Properties = {
    HeaderImage = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    ProgressIndicator = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    DetailContainer = {
      default = EntityId()
    },
    InProgressText = {
      default = EntityId()
    },
    InProgressBg = {
      default = EntityId()
    },
    TimeAmount = {
      default = EntityId()
    },
    TimeRemaining = {
      default = EntityId()
    },
    TimeLabel = {
      default = EntityId()
    },
    ConfirmationButton = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    TierText1 = {
      default = EntityId()
    },
    TierText2 = {
      default = EntityId()
    },
    OverCompleteLabel = {
      default = EntityId()
    },
    InProgressLabel = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_ProjectDetailPopup)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local territoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function TerritoryPlanning_ProjectDetailPopup:OnInit()
  BaseElement.OnInit(self)
  self.ButtonClose:SetCallback(self.OnClose, self)
end
function TerritoryPlanning_ProjectDetailPopup:OnShutdown()
end
function TerritoryPlanning_ProjectDetailPopup:SetDetailPopupData(upgradeData, callbackSelf, callbackFn)
  UiImageBus.Event.SetSpritePathname(self.Properties.HeaderImage, upgradeData.projectImage)
  UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, upgradeData.projectTitle, eUiTextSet_SetLocalized)
  if upgradeData.projectCurrentTier then
    local currentTier = upgradeData.projectCurrentTier
    local nextTier = upgradeData.projectCurrentTier + 1
    UiTextBus.Event.SetText(self.Properties.TierText1, currentTier)
    UiTextBus.Event.SetText(self.Properties.TierText2, nextTier)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ProgressIndicator, upgradeData.maxLevel ~= nil)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, upgradeData.projectDescription, eUiTextSet_SetLocalized)
  self.DetailContainer:SetProjectDetailData(upgradeData)
  local now = timeHelpers:ServerNow()
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  local dueTime = territoryDataHandler:GetUpkeepDueTime(territoryId)
  local upkeepOverdue = now > dueTime
  local isActive = upgradeData:IsActive()
  UiElementBus.Event.SetIsEnabled(self.Properties.InProgressBg, isActive)
  UiElementBus.Event.SetIsEnabled(self.Properties.TimeLabel, not isActive)
  local territoryOwnerGuildId = territoryDataHandler:GetGoverningGuildId(territoryId)
  local isClaimedTerritory = territoryOwnerGuildId and territoryOwnerGuildId:IsValid()
  local hasPermission = TerritoryGovernanceRequestBus.Broadcast.HasCurrentTerritoryGuildPrivilege(eGuildPrivilegeId_Territory_Management)
  if hasPermission and isClaimedTerritory and not upkeepOverdue then
    self.ConfirmationButton:SetButtonStyle(self.ConfirmationButton.BUTTON_STYLE_HERO)
    self.ConfirmationButton:StartStopImageSequence(true)
    if isActive then
      self.ConfirmationButton:SetButtonStyle(self.ConfirmationButton.BUTTON_STYLE_DEFAULT)
      self.ConfirmationButton:StartStopImageSequence(false)
    end
  elseif not isClaimedTerritory then
    self.ConfirmationButton:SetTooltip("@ui_project_territory_not_claimed")
  elseif not hasPermission then
    self.ConfirmationButton:SetTooltip("@ui_project_nopermission")
  elseif upkeepOverdue then
    self.ConfirmationButton:SetTooltip("@ui_project_tooltip_upkeep_overdue")
  end
  self.ConfirmationButton:SetEnabled(hasPermission and not upkeepOverdue and not upgradeData:IsComplete())
  self.ConfirmationButton:SetCallback(callbackFn, callbackSelf)
  if isActive then
    self.ConfirmationButton:SetText("@ui_cancel_town_project")
    if upgradeData.currentProgress > upgradeData.progressionNeeded then
      local timeRemaining = upgradeData:GetTimeRemaining()
      self.TimeRemaining:SetCurrentCountdownTime(timeRemaining)
      self.TimeRemaining:SetOmitZeros(true)
      UiElementBus.Event.SetIsEnabled(self.Properties.OverCompleteLabel, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.InProgressLabel, false)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.OverCompleteLabel, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.InProgressLabel, true)
    end
  else
    local minCompletionTime = upgradeData.projectTime == 0 and "@ui_none" or timeHelpers:ConvertToLargestTimeEstimate(upgradeData.projectTime * timeHelpers.secondsInMinute, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeAmount, minCompletionTime, eUiTextSet_SetLocalized)
    local buttonText
    local skipLocalization = false
    if upkeepOverdue then
      buttonText = "@ui_project_button_upkeep_overdue"
    else
      buttonText = GetLocalizedReplacementText("@ui_start_town_project_cost", {
        cost = GetLocalizedCurrency(upgradeData.cost)
      })
      skipLocalization = true
    end
    self.ConfirmationButton:SetText(buttonText, skipLocalization)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function TerritoryPlanning_ProjectDetailPopup:OnClose()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      self.ConfirmationButton:StartStopImageSequence(false)
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self.IsClosing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
return TerritoryPlanning_ProjectDetailPopup
