local StatusEffect = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Duration = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    },
    StackCountText = {
      default = EntityId()
    }
  }
}
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(StatusEffect)
local InvalidEntityId = EntityId()
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function StatusEffect:OnInit()
  BaseScreen.OnInit(self)
end
function StatusEffect:ProcessDescription()
  local hasTooltip = self.description and string.len(self.description) > 0
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.TooltipSetter, hasTooltip)
  if not hasTooltip then
    self.description = nil
  else
    self.description = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(self.description)
  end
  self.TooltipSetter:SetSimpleTooltip(self.description)
end
function StatusEffect:UpdateText()
  if not self.name then
    return
  end
  self:ProcessDescription()
  TimingUtils:StopDelay(self)
  self:UpdateDuration()
end
function StatusEffect:SetStatusEffectInfo(name, desc, icon, endTime)
  self.name = name
  self.description = desc
  self.icon = icon
  self.endTime = endTime
  self:UpdateText()
end
function StatusEffect:SetStatusEffectDataPath(imageDirectory, dataPath, owner, activeStatusCallback)
  self.imageDirectory = imageDirectory
  self.owner = owner
  self.activeStatusCallback = activeStatusCallback
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".Icon", function(self, icon)
    self.icon = icon
    if not icon or string.len(icon) == 0 then
      self.icon = nil
      self.activeStatusCallback(self.owner, false)
      return
    end
    local imagePath = string.format("%s/%s.dds", self.imageDirectory, icon)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, imagePath)
    if self.name and self.icon then
      self.activeStatusCallback(self.owner, true)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".Name", function(self, name)
    self.name = name
    if not name or string.len(name) == 0 then
      self.name = nil
      self.activeStatusCallback(self.owner, false)
      return
    end
    if self.name and self.icon then
      self.activeStatusCallback(self.owner, true)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".Description", function(self, desc)
    self.description = desc
    self:ProcessDescription()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".EndTime", function(self, endTime)
    self.endTime = endTime
    if not endTime then
      return
    end
    TimingUtils:StopDelay(self)
    self:UpdateDuration()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".IsNegative", function(self, isNegative)
    self.isNegative = isNegative
    UiImageBus.Event.SetColor(self.entityId, self.isNegative and self.UIStyle.COLOR_RED_DARK or self.UIStyle.COLOR_BLACK)
    UiTextBus.Event.SetColor(self.Properties.Duration, self.isNegative and self.UIStyle.COLOR_YELLOW or self.UIStyle.COLOR_WHITE)
    UiTextBus.Event.SetColor(self.Properties.StackCountText, self.isNegative and self.UIStyle.COLOR_YELLOW or self.UIStyle.COLOR_WHITE)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".StackSize", function(self, stackSize)
    self.stackSize = stackSize or 1
    UiElementBus.Event.SetIsEnabled(self.Properties.StackCountText, self.stackSize > 1)
    if self.stackSize > 1 then
      UiTextBus.Event.SetText(self.Properties.StackCountText, "\195\151" .. self.stackSize)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.StackCountText, 0.3, {scaleX = 1.2, scaleY = 1.2}, tweenerCommon.scaleTo1)
    end
  end)
end
function StatusEffect:UpdateDuration()
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  if not now then
    TimingUtils:Delay(1, self, self.UpdateDuration)
    return
  end
  local duration = self.endTime:Subtract(now):ToSecondsUnrounded()
  local durationText = TimeHelpers:ConvertToShorthandString(duration, false, true)
  local nextUpdate = 0
  if duration <= 0 then
    durationText = "\226\128\148"
  elseif duration <= 60 then
    durationText = TimeHelpers:ConvertToShorthandString(math.max(duration, 1))
    nextUpdate = 0.5
  elseif duration <= 120 then
    nextUpdate = duration - 60
  elseif duration <= 3600 then
    nextUpdate = 60
  elseif duration < 7200 then
    nextUpdate = duration - 3600
  else
    nextUpdate = 3600
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Duration, durationText, eUiTextSet_SetLocalized)
  if 0 < nextUpdate then
    TimingUtils:Delay(nextUpdate, self, self.UpdateDuration)
  end
end
return StatusEffect
