local TerritoryPlanning_ProjectButtonGridItem = {
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
    Disabled = {
      default = EntityId()
    },
    IsActive = {
      default = EntityId()
    },
    StyleGrid = {
      Container = {
        default = EntityId()
      },
      LabelText = {
        default = EntityId()
      },
      Description = {
        default = EntityId()
      },
      Cost = {
        default = EntityId()
      },
      ActionText = {
        default = EntityId()
      },
      Percentage = {
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
      }
    }
  },
  STYLE_GRID = 0,
  STYLE_RIGHT = 1,
  STYLE_LEFT = 2
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_ProjectButtonGridItem)
function TerritoryPlanning_ProjectButtonGridItem:OnInit()
  BaseElement.OnInit(self)
  self.style = self.STYLE_GRID
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, canvasId)
end
function TerritoryPlanning_ProjectButtonGridItem:OnShutdown()
end
function TerritoryPlanning_ProjectButtonGridItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function TerritoryPlanning_ProjectButtonGridItem:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function TerritoryPlanning_ProjectButtonGridItem:GetHorizontalSpacing()
  return 20
end
function TerritoryPlanning_ProjectButtonGridItem:OnCanvasEnabledChanged(isEnabled)
end
function TerritoryPlanning_ProjectButtonGridItem:SetGridItemData(projectGroupData)
  UiElementBus.Event.SetIsEnabled(self.entityId, projectGroupData ~= nil)
  if projectGroupData then
    self.maxLevel = #projectGroupData
    self.currentLevel = self.maxLevel
    local upgradeData = projectGroupData[self.maxLevel]
    for i, projectData in ipairs(projectGroupData) do
      if not projectData:IsComplete() then
        self.currentLevel = i - 1
        upgradeData = projectData
        break
      end
    end
    local isActive = upgradeData:IsActive()
    local isAvailable = upgradeData:IsAvailable()
    local isComplete = upgradeData:IsComplete()
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, upgradeData.projectIcon)
    UiElementBus.Event.SetIsEnabled(self.Properties.IsActive, isActive)
    local showProgress = upgradeData.upgradeType ~= eTerritoryUpgradeType_Lifestyle
    UiElementBus.Event.SetIsEnabled(self.Properties.ProgressBar, showProgress)
    if showProgress then
      self.ProgressBar:SetLevelData(self.currentLevel, self.maxLevel)
    end
    if isActive then
      local percentCompleteText = GetLocalizedReplacementText("@ui_upgradebutton_percentcomplete", {
        percentComplete = string.format("%.1f", upgradeData:GetProgressPercent() * 100)
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.StyleGrid.Percentage, percentCompleteText, eUiTextSet_SetAsIs)
      projectGroupData.isActiveCallbackFn(projectGroupData.callbackSelf, upgradeData, self.entityId)
      self.ScriptedEntityTweener:Set(self.Properties.ProgressBar, {y = 140})
      UiTextBus.Event.SetColor(self.Properties.StyleRight.LabelText, self.UIStyle.COLOR_YELLOW)
      UiTextBus.Event.SetColor(self.Properties.StyleLeft.LabelText, self.UIStyle.COLOR_YELLOW)
    else
      self.ScriptedEntityTweener:Set(self.Properties.ProgressBar, {y = 126})
      UiTextBus.Event.SetColor(self.Properties.StyleRight.LabelText, self.UIStyle.COLOR_TAN)
      UiTextBus.Event.SetColor(self.Properties.StyleLeft.LabelText, self.UIStyle.COLOR_TAN)
    end
    if isComplete or not isAvailable then
      self.ScriptedEntityTweener:Set(self.Properties.Disabled, {opacity = 1})
      self.callbackSelf = nil
      self.callbackFn = nil
    else
      self.ScriptedEntityTweener:Set(self.Properties.Disabled, {opacity = 0})
      self.callbackSelf = projectGroupData.callbackSelf
      self.callbackFn = projectGroupData.callbackFn
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.StyleGrid.Container, self.style == self.STYLE_GRID)
    UiElementBus.Event.SetIsEnabled(self.Properties.StyleRight.Container, self.style == self.STYLE_RIGHT)
    UiElementBus.Event.SetIsEnabled(self.Properties.StyleLeft.Container, self.style == self.STYLE_LEFT)
    if self.style == self.STYLE_RIGHT or self.style == self.STYLE_LEFT then
      local side = self.style == self.STYLE_RIGHT and self.Properties.StyleRight or self.Properties.StyleLeft
      UiTextBus.Event.SetTextWithFlags(side.LabelText, upgradeData.projectButtonLabel, eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(side.ActiveProjectText, isActive)
      UiElementBus.Event.SetIsEnabled(side.UpgradeCostContainer, not isActive)
      if not isActive then
        UiTextBus.Event.SetTextWithFlags(side.UpgradeCostText, GetLocalizedCurrency(upgradeData.cost), eUiTextSet_SetAsIs)
      end
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.StyleGrid.LabelText, upgradeData.projectButtonLabel, eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.StyleGrid.Description, upgradeData.projectDescription, eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.StyleGrid.Cost, not isActive)
      UiElementBus.Event.SetIsEnabled(self.Properties.StyleGrid.Percentage, isActive)
      if not isActive then
        if isComplete then
          UiElementBus.Event.SetIsEnabled(self.Properties.StyleGrid.Cost, false)
          UiTextBus.Event.SetTextWithFlags(self.Properties.StyleGrid.ActionText, "@ui_complete", eUiTextSet_SetLocalized)
        else
          UiElementBus.Event.SetIsEnabled(self.Properties.StyleGrid.Cost, true)
          UiTextBus.Event.SetTextWithFlags(self.Properties.StyleGrid.Cost, GetLocalizedCurrency(upgradeData.cost), eUiTextSet_SetAsIs)
          UiTextBus.Event.SetTextWithFlags(self.Properties.StyleGrid.ActionText, "@ui_activate", eUiTextSet_SetLocalized)
        end
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.StyleGrid.ActionText, "@ui_inprogress", eUiTextSet_SetLocalized)
      end
    end
    UiElementBus.Event.SetIsEnabled(self.entityId, isAvailable)
    self.upgradeData = upgradeData
    upgradeData.maxLevel = self.maxLevel
    upgradeData.currentLevel = self.currentLevel
  else
    self.callbackSelf = nil
    self.callbackFn = nil
    self.upgradeData = nil
  end
end
function TerritoryPlanning_ProjectButtonGridItem:SetProjectButtonStyle(style)
  self.style = style
end
function TerritoryPlanning_ProjectButtonGridItem:OnTerritoryUpgradeFocus()
  local isComplete = self.upgradeData and self.upgradeData:IsComplete()
  if not isComplete then
    self.audioHelper:PlaySound(self.audioHelper.Crafting_Material_Hover)
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  end
  local timeRemaining = self.upgradeData:GetTimeRemaining()
end
function TerritoryPlanning_ProjectButtonGridItem:OnTerritoryUpgradeUnfocus()
  local isComplete = self.upgradeData and self.upgradeData:IsComplete()
  if not isComplete then
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  end
end
function TerritoryPlanning_ProjectButtonGridItem:OnTerritoryUpgradeClick()
  if self.callbackSelf then
    self.callbackFn(self.callbackSelf, self.upgradeData)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return TerritoryPlanning_ProjectButtonGridItem
