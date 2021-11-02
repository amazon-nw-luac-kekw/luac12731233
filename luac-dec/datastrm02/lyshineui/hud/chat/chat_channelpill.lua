local Chat_ChannelPill = {
  Properties = {
    Bg = {
      default = EntityId()
    },
    ChannelName = {
      default = EntityId()
    },
    ChannelIcon = {
      default = EntityId()
    }
  },
  PADDING = 3,
  MARGIN = 12,
  width = 0,
  isCollapsed = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Chat_ChannelPill)
function Chat_ChannelPill:OnInit()
  self.cachedChannelNameWidths = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    self.cachedChannelNameWidths = {}
    self:SizeToText()
  end)
end
function Chat_ChannelPill:SetChannelData(channelData, skipResize)
  self.channelDataDisplayName = channelData.displayName
  UiImageBus.Event.SetSpritePathname(self.Properties.ChannelIcon, channelData.widgetIcon)
  UiImageBus.Event.SetColor(self.Properties.ChannelIcon, channelData.color)
  if not skipResize then
    UiImageBus.Event.SetColor(self.Properties.Bg, channelData.color)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ChannelName, channelData.displayName, eUiTextSet_SetLocalized)
    self:SizeToText()
  end
end
function Chat_ChannelPill:Expand(stayOpenTime, instant)
  if instant then
    self.ScriptedEntityTweener:Set(self.entityId, {
      layoutTargetWidth = self.width,
      w = self.width
    })
    self.ScriptedEntityTweener:Set(self.Properties.ChannelName, {opacity = 1})
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {w = 0, layoutTargetWidth = 0}, {
      w = self.width,
      layoutTargetWidth = self.width,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ChannelName, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  end
  self.isCollapsed = false
  if stayOpenTime == -1 then
    self.lockOpen = true
  elseif stayOpenTime ~= nil then
    self.lockOpen = false
    if 0 < stayOpenTime then
      self:Collapse(stayOpenTime)
    end
  end
end
function Chat_ChannelPill:SetLockedOpen(lockOpen)
  self.lockOpen = lockOpen
  if self.isCollapsed and lockOpen then
    self:Expand()
  end
end
function Chat_ChannelPill:Collapse(delay, animTime)
  if self.lockOpen then
    return
  end
  delay = delay ~= nil and delay or 0
  animTime = animTime ~= nil and animTime or 0.3
  self.isCollapsed = true
  local targetWidth = UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
  if targetWidth ~= 0 then
    if delay == 0 and animTime == 0 then
      self.ScriptedEntityTweener:Set(self.entityId, {layoutTargetWidth = 0, w = 0})
      self.ScriptedEntityTweener:Set(self.Properties.ChannelName, {opacity = 0})
      return
    else
      self.ScriptedEntityTweener:Play(self.entityId, animTime, {
        layoutTargetWidth = 0,
        w = 0,
        ease = "QuadOut",
        delay = delay + animTime / 2
      })
      self.ScriptedEntityTweener:Play(self.Properties.ChannelName, animTime, {
        opacity = 0,
        ease = "QuadOut",
        delay = delay
      })
    end
  end
end
function Chat_ChannelPill:SizeToText(doWidthCalculationOnly)
  if not self.channelDataDisplayName then
    return
  end
  if not self.cachedChannelNameWidths[self.channelDataDisplayName] then
    local nameWidth = UiTextBus.Event.GetTextWidth(self.Properties.ChannelName)
    self.cachedChannelNameWidths[self.channelDataDisplayName] = nameWidth
  end
  local textWidth = self.cachedChannelNameWidths[self.channelDataDisplayName]
  self.width = textWidth + self.PADDING * 2 + self.MARGIN
  if not self.isCollapsed and not doWidthCalculationOnly then
    self.ScriptedEntityTweener:Set(self.entityId, {
      layoutTargetWidth = self.width,
      w = self.width
    })
  end
end
function Chat_ChannelPill:SetTextSize(textSize)
  if self.lastTextSize ~= textSize then
    UiTextBus.Event.SetFontSize(self.Properties.ChannelName, textSize)
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, textSize + self.PADDING * 2)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ChannelIcon, textSize)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ChannelIcon, textSize)
    self:CacheChannelNameWidths()
    self:SizeToText()
    self.lastTextSize = textSize
  end
end
function Chat_ChannelPill:OnHoverIconStart()
  if self.isCollapsed then
    self:Expand()
  end
end
function Chat_ChannelPill:OnHoverIconEnd()
  if not self.isCollapsed then
    self:Collapse()
  end
end
function Chat_ChannelPill:GetWidth()
  return self.width
end
return Chat_ChannelPill
