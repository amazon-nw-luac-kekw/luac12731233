local WarPhase = {
  Properties = {
    Background = {
      default = EntityId()
    },
    TimeFill = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    Remaining = {
      default = EntityId()
    },
    RemainingTime = {
      default = EntityId()
    }
  },
  isActivePhase = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WarPhase)
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function WarPhase:OnInit()
  BaseElement:OnInit(self)
  self.timeHelpers = timeHelpers
end
function WarPhase:SetPhase(phaseType, isAttacker, wasExtended)
  if wasExtended then
    isAttacker = not isAttacker
  end
  isAttacker = isAttacker or nil
  self.phaseType = phaseType
  if self.phaseType == eWarPhase_PreWar then
    UiImageBus.Event.SetColor(self.Background, self.UIStyle.COLOR_WAR_PHASE_SCOUTING_DARK)
    UiElementBus.Event.SetIsEnabled(self.Properties.Title, false)
  elseif self.phaseType == eWarPhase_War then
    UiImageBus.Event.SetColor(self.Background, self.UIStyle.COLOR_WAR_PHASE_BATTLE_DARK)
    UiElementBus.Event.SetIsEnabled(self.Properties.Title, false)
  elseif self.phaseType == eWarPhase_Conquest then
    if isAttacker then
      UiImageBus.Event.SetColor(self.Background, self.UIStyle.COLOR_WAR_PHASE_CONQUEST_DARK)
    else
      UiImageBus.Event.SetColor(self.Background, self.UIStyle.COLOR_WAR_PHASE_CONQUEST_DEFEND_DARK)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Title, true)
  elseif self.phaseType == eWarPhase_Resolution then
    UiImageBus.Event.SetColor(self.Background, self.UIStyle.COLOR_WAR_PHASE_RESOLUTION_DARK)
    UiElementBus.Event.SetIsEnabled(self.Properties.Title, false)
  elseif self.phaseType == eWarPhase_Complete then
    UiImageBus.Event.SetColor(self.entityId, ColorRgba(0, 0, 0, 0))
    UiElementBus.Event.SetIsEnabled(self.Properties.Title, false)
  end
  local warPhaseText = dominionCommon:GetWarPhaseText(self.phaseType)
  if warPhaseText then
    if self.phaseType == eWarPhase_Conquest then
      if isAttacker then
        warPhaseText = "@ui_warphase_conquest_attack"
      else
        warPhaseText = "@ui_warphase_conquest_defend"
      end
    end
    UiTextBus.Event.SetTextWithFlags(self.Title, warPhaseText, eUiTextSet_SetLocalized)
  end
end
function WarPhase:SetTimeTexts(dateTextEntity, timeTextEntity, time)
  local dateString = timeHelpers:GetLocalizedAbbrevDate(time)
  UiTextBus.Event.SetText(dateTextEntity, dateString)
  UiTextBus.Event.SetText(timeTextEntity, self.timeHelpers:GetLocalizedServerTime(time, true, false))
end
function WarPhase:SetEndTime(time)
  self.endTime = time
end
function WarPhase:SetIsActivePhase(value)
  self.isActivePhase = value
  if self.Properties.Remaining:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Remaining, value)
    if not value then
      self:SetTimeFill(0)
    end
  end
end
function WarPhase:UpdateTimeRemaining()
  if not self.isActivePhase then
    return
  end
  local timeRemaining = self.endTime - timeHelpers:ServerSecondsSinceEpoch()
  if timeRemaining < 0 then
    return
  end
  local timeText = self.timeHelpers:ConvertToShorthandString(timeRemaining, true)
  if self.Properties.RemainingTime:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.RemainingTime, timeText, eUiTextSet_SetLocalized)
  end
end
function WarPhase:SetTimeFill(fillPercentage)
  if not self.isActivePhase then
    return
  end
  fillPercentage = Math.Clamp(fillPercentage, 0, 1)
  UiTransform2dBus.Event.SetAnchorsScript(self.TimeFill, UiAnchors(fillPercentage, 0, 1, 1))
end
return WarPhase
