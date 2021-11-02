local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local TerritoryPlanning_ProjectButton = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    ProgressBar = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    IsActiveRing = {
      default = EntityId()
    },
    IsActive = {
      default = EntityId()
    },
    PercentBg = {
      default = EntityId()
    },
    PercentProgressBar = {
      default = EntityId()
    },
    PercentCompleteText = {
      default = EntityId()
    },
    StyleGrid = {
      Container = {
        default = EntityId()
      },
      LabelText = {
        default = EntityId()
      }
    },
    StyleRight = {
      Container = {
        default = EntityId()
      },
      LabelText = {
        default = EntityId()
      },
      UpgradeCostContainer = {
        default = EntityId()
      },
      UpgradeCostText = {
        default = EntityId()
      },
      ActiveProjectText = {
        default = EntityId()
      },
      CompleteText = {
        default = EntityId()
      }
    },
    StyleLeft = {
      Container = {
        default = EntityId()
      },
      LabelText = {
        default = EntityId()
      },
      UpgradeCostContainer = {
        default = EntityId()
      },
      UpgradeCostText = {
        default = EntityId()
      },
      ActiveProjectText = {
        default = EntityId()
      },
      CompleteText = {
        default = EntityId()
      }
    }
  },
  STYLE_GRID = 0,
  STYLE_RIGHT = 1,
  STYLE_LEFT = 2
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_ProjectButton)
function TerritoryPlanning_ProjectButton:OnInit()
  BaseElement.OnInit(self)
  self.style = self.STYLE_GRID
  UiTextBus.Event.SetColor(self.Properties.StyleLeft.CompleteText, self.UIStyle.COLOR_GREEN_MEDIUM)
  UiTextBus.Event.SetColor(self.Properties.StyleRight.CompleteText, self.UIStyle.COLOR_GREEN_MEDIUM)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, canvasId)
end
function TerritoryPlanning_ProjectButton:OnShutdown()
  TimingUtils:StopDelay(self)
  self.ScriptedEntityTweener:Stop(self.Properties.IsActiveRing)
  self.ScriptedEntityTweener:Stop(self.Properties.IsActive)
end
function TerritoryPlanning_ProjectButton:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function TerritoryPlanning_ProjectButton:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function TerritoryPlanning_ProjectButton:GetHorizontalSpacing()
  return 20
end
function TerritoryPlanning_ProjectButton:OnCanvasEnabledChanged(isEnabled)
  if isEnabled then
    self.ScriptedEntityTweener:Play(self.Properties.IsActiveRing, 4, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Play(self.Properties.IsActive, 30, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.IsActiveRing)
    self.ScriptedEntityTweener:Stop(self.Properties.IsActive)
  end
end
function TerritoryPlanning_ProjectButton:UpdateCooldownText(side, timeRemaining)
  if 0 < timeRemaining then
    UiTextBus.Event.SetText(side.CompleteText, timeHelpers:ConvertSecondsToHrsMinSecString(timeRemaining))
    TimingUtils:Delay(1, self, function()
      self:UpdateCooldownText(side, timeRemaining - 1)
    end)
  end
end
function TerritoryPlanning_ProjectButton:SetGridItemData(projectGroupData)
  TimingUtils:StopDelay(self)
  UiElementBus.Event.SetIsEnabled(self.entityId, projectGroupData ~= nil)
  if projectGroupData then
    self.maxLevel = #projectGroupData
    self.currentLevel = self.maxLevel
    local upgradeData = projectGroupData[self.maxLevel]
    for i, projectData in ipairs(projectGroupData) do
      if not projectData:IsComplete() or projectData:IsActive() then
        self.currentLevel = i - 1
        upgradeData = projectData
        break
      end
    end
    local isActive = upgradeData:IsActive()
    local isComplete = upgradeData:IsComplete()
    local progressLevel = self.currentLevel
    if isComplete and isActive then
      progressLevel = progressLevel + 1
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, upgradeData.projectIcon)
    UiElementBus.Event.SetIsEnabled(self.Properties.IsActiveRing, isActive)
    UiElementBus.Event.SetIsEnabled(self.Properties.IsActive, isActive)
    local showProgress = upgradeData.upgradeType ~= eTerritoryUpgradeType_Lifestyle
    UiElementBus.Event.SetIsEnabled(self.Properties.ProgressBar, showProgress)
    if showProgress then
      self.ProgressBar:SetLevelData(progressLevel, self.maxLevel)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.PercentBg, isActive)
    if isActive then
      local percentCompleteText = GetLocalizedReplacementText("@ui_upgradebutton_percentcomplete", {
        percentComplete = string.format("%.1f", upgradeData:GetProgressPercent() * 100)
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.PercentCompleteText, percentCompleteText, eUiTextSet_SetAsIs)
      UiImageBus.Event.SetFillAmount(self.Properties.PercentProgressBar, upgradeData:GetProgressPercent())
      projectGroupData.isActiveCallbackFn(projectGroupData.callbackSelf, upgradeData, self.entityId)
      self.ScriptedEntityTweener:Set(self.Properties.ProgressBar, {y = 140})
      UiTextBus.Event.SetColor(self.Properties.StyleRight.LabelText, self.UIStyle.COLOR_YELLOW)
      UiTextBus.Event.SetColor(self.Properties.StyleLeft.LabelText, self.UIStyle.COLOR_YELLOW)
    else
      self.ScriptedEntityTweener:Set(self.Properties.ProgressBar, {y = 126})
      UiTextBus.Event.SetColor(self.Properties.StyleRight.LabelText, self.UIStyle.COLOR_TAN)
      UiTextBus.Event.SetColor(self.Properties.StyleLeft.LabelText, self.UIStyle.COLOR_TAN)
    end
    local isAvailable = upgradeData:IsAvailable()
    if isAvailable then
      self.callbackSelf = projectGroupData.callbackSelf
      self.callbackFn = projectGroupData.callbackFn
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.StyleGrid.Container, self.style == self.STYLE_GRID)
    UiElementBus.Event.SetIsEnabled(self.Properties.StyleRight.Container, self.style == self.STYLE_RIGHT)
    UiElementBus.Event.SetIsEnabled(self.Properties.StyleLeft.Container, self.style == self.STYLE_LEFT)
    if self.style == self.STYLE_RIGHT or self.style == self.STYLE_LEFT then
      local side = self.style == self.STYLE_RIGHT and self.Properties.StyleRight or self.Properties.StyleLeft
      if isComplete and upgradeData.projectCategory ~= eSettlementProgressionCategory_FortHardPoints then
        local completedTier = upgradeData.projectCurrentTier + 1
        local completeText = GetLocalizedReplacementText("@ui_upgradebutton_completed", {
          category = upgradeData.projectCategoryName,
          tier = completedTier
        })
        UiTextBus.Event.SetTextWithFlags(side.LabelText, completeText, eUiTextSet_SetAsIs)
      else
        UiTextBus.Event.SetTextWithFlags(side.LabelText, upgradeData.projectButtonLabel, eUiTextSet_SetLocalized)
      end
      UiElementBus.Event.SetIsEnabled(side.ActiveProjectText, isActive and not isComplete)
      if isComplete and isActive then
        self:UpdateCooldownText(side, upgradeData:GetTimeRemaining())
      else
        UiTextBus.Event.SetTextWithFlags(side.CompleteText, "@ui_upgradebutton_upgradescomplete", eUiTextSet_SetLocalized)
      end
      UiElementBus.Event.SetIsEnabled(side.CompleteText, isComplete)
      local showUpgradeCost = not isActive and not isComplete
      UiElementBus.Event.SetIsEnabled(side.UpgradeCostContainer, showUpgradeCost)
      if showUpgradeCost then
        UiTextBus.Event.SetTextWithFlags(side.UpgradeCostText, GetLocalizedCurrency(upgradeData.cost), eUiTextSet_SetAsIs)
      end
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.StyleGrid.LabelText, upgradeData.projectTitle, eUiTextSet_SetLocalized)
    end
    UiElementBus.Event.SetIsEnabled(self.entityId, isAvailable)
    UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, not isComplete)
    self.upgradeData = upgradeData
  else
    self.callbackSelf = nil
    self.callbackFn = nil
    self.upgradeData = nil
  end
end
function TerritoryPlanning_ProjectButton:SetProjectButtonStyle(style)
  self.style = style
end
function TerritoryPlanning_ProjectButton:OnTerritoryUpgradeFocus()
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {
    opacity = 0,
    scaleX = 1.1,
    scaleY = 1.1
  }, {
    opacity = 1,
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  local isActive = self.upgradeData:IsActive()
  local timeRemaining = self.upgradeData:GetTimeRemaining()
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Material_Hover)
  DynamicBus.TerritoryPlanningToolip.Broadcast.OnTooltipOpen(self.entityId, self.upgradeData.projectImage, self.upgradeData.projectTitle, self.upgradeData.projectDescription, self.currentLevel, self.maxLevel, isActive, timeRemaining, self.upgradeData.cost, self.upgradeData.projectCurrentTier, self.upgradeData.currentProgress, self.upgradeData.progressionNeeded)
end
function TerritoryPlanning_ProjectButton:OnTerritoryUpgradeUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  DynamicBus.TerritoryPlanningToolip.Broadcast.CloseTooltip()
end
function TerritoryPlanning_ProjectButton:OnTerritoryUpgradeClick()
  if self.callbackSelf then
    self.callbackFn(self.callbackSelf, self.upgradeData)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return TerritoryPlanning_ProjectButton
