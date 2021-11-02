local TerritoryPlanning_Tooltip = {
  Properties = {
    ProjectImage = {
      default = EntityId()
    },
    ProjectText = {
      default = EntityId()
    },
    ProgressIndicator = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    CurrentProjectContainer = {
      default = EntityId()
    },
    CurrentProjectTime = {
      default = EntityId()
    },
    PointerImage1 = {
      default = EntityId()
    },
    CostText = {
      default = EntityId()
    },
    CostContainer = {
      default = EntityId()
    },
    TierText1 = {
      default = EntityId()
    },
    TierText2 = {
      default = EntityId()
    },
    TierContainer = {
      default = EntityId()
    },
    OverCompleteLabel = {
      default = EntityId()
    },
    CurrentProjectLabel = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_Tooltip)
function TerritoryPlanning_Tooltip:OnInit()
  BaseElement.OnInit(self)
  DynamicBus.TerritoryPlanningToolip.Connect(self.entityId, self)
end
function TerritoryPlanning_Tooltip:OnShutdown()
  DynamicBus.TerritoryPlanningToolip.Disconnect(self.entityId, self)
end
function TerritoryPlanning_Tooltip:OnTooltipOpen(sourceEntity, projectImage, text, description, currentLevel, maxLevel, isActive, timeRemaining, cost, projectCurrentTier, currentProgress, progressionNeeded)
  UiImageBus.Event.SetSpritePathname(self.Properties.ProjectImage, projectImage)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ProjectText, text, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Description, description, eUiTextSet_SetLocalized)
  local hasLevel = currentLevel and maxLevel
  UiElementBus.Event.SetIsEnabled(self.Properties.ProgressIndicator, hasLevel)
  if hasLevel then
    self.ProgressIndicator:SetLevelData(currentLevel, maxLevel)
  end
  if projectCurrentTier then
    local nextTier = projectCurrentTier + 1
    UiTextBus.Event.SetText(self.Properties.TierText1, projectCurrentTier)
    UiTextBus.Event.SetText(self.Properties.TierText2, nextTier)
    self.ScriptedEntityTweener:Set(self.entityId, {h = 556})
    UiElementBus.Event.SetIsEnabled(self.Properties.TierContainer, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TierContainer, false)
    self.ScriptedEntityTweener:Set(self.entityId, {h = 426})
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrentProjectContainer, isActive)
  UiElementBus.Event.SetIsEnabled(self.Properties.CostContainer, not isActive)
  if isActive then
    if progressionNeeded <= currentProgress then
      self.CurrentProjectTime:SetCurrentCountdownTime(timeRemaining)
      self.CurrentProjectTime:SetOmitZeros(true)
      UiElementBus.Event.SetIsEnabled(self.Properties.OverCompleteLabel, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.CurrentProjectLabel, false)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.OverCompleteLabel, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.CurrentProjectLabel, true)
    end
  else
    UiTextBus.Event.SetText(self.Properties.CostText, GetLocalizedCurrency(cost))
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.3
  })
  local viewportPos = UiTransformBus.Event.GetViewportPosition(sourceEntity)
  viewportPos.x = viewportPos.x + 60
  viewportPos.y = viewportPos.y + 10
  PositionEntityOnScreen(self.entityId, viewportPos)
end
function TerritoryPlanning_Tooltip:CloseTooltip()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
return TerritoryPlanning_Tooltip
