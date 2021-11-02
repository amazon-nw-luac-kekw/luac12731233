EArchetypeItemState = {
  Idle = 0,
  Hover = 1,
  Selected = 2
}
local ArchetypeScreenItem = {
  Properties = {
    Name = {
      default = EntityId()
    },
    Attribute = {
      default = EntityId()
    },
    Skill = {
      default = EntityId()
    },
    Portrait = {
      default = EntityId()
    },
    ButtonHighlight = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  },
  pulseTimeline = nil,
  itemIndex = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ArchetypeScreenItem)
function ArchetypeScreenItem:OnInit()
  BaseElement.OnInit(self)
  self.pulseTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.pulseTimeline:Add(self.Properties.ButtonHighlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.4})
  self.pulseTimeline:Add(self.Properties.ButtonHighlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.9})
  self.pulseTimeline:Add(self.Properties.ButtonHighlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
    opacity = 0.9,
    onComplete = function()
      self.pulseTimeline:Play()
    end
  })
  self:SetState(EArchetypeItemState.Idle)
end
function ArchetypeScreenItem:OnShutdown()
  if self.pulseTimeline ~= nil then
    self.pulseTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.pulseTimeline)
  end
end
function ArchetypeScreenItem:SetName(name)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Name, name, eUiTextSet_SetLocalized)
end
function ArchetypeScreenItem:SetAttribute(attr)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Attribute, attr, eUiTextSet_SetLocalized)
end
function ArchetypeScreenItem:SetSkill(skill)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Skill, skill, eUiTextSet_SetLocalized)
end
function ArchetypeScreenItem:SetPortrait(path)
  UiImageBus.Event.SetSpritePathname(self.Properties.Portrait, path)
end
function ArchetypeScreenItem:SetTooltip(value)
  self.ButtonTooltipSetter:SetSimpleTooltip(value)
end
function ArchetypeScreenItem:SetItemIndex(index)
  self.itemIndex = index
end
function ArchetypeScreenItem:SetState(newState)
  if self.state == newState then
    return
  end
  local animDuration = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.state = newState
  if newState == EArchetypeItemState.Idle then
    self.ScriptedEntityTweener:Play(self.Properties.Name, animDuration, {
      textColor = self.UIStyle.COLOR_TAN,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.Portrait, animDuration, {opacity = 0.7, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonHighlight, animDuration, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {opacity = 0.7, ease = "QuadOut"})
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  elseif newState == EArchetypeItemState.Hover then
    self.ScriptedEntityTweener:Play(self.Properties.Name, animDuration, {
      textColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.Portrait, animDuration, {opacity = 0.9, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {opacity = 0.8, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.9, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = 0.9,
      delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
      onComplete = function()
        self.pulseTimeline:Play()
      end
    })
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
    self.audioHelper:PlaySound(self.audioHelper.OnHover_CharacterCreation)
  elseif newState == EArchetypeItemState.Selected then
    self.ScriptedEntityTweener:Play(self.Properties.Name, animDuration, {
      textColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.Portrait, animDuration, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonHighlight, animDuration, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {opacity = 0.9, ease = "QuadOut"})
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
return ArchetypeScreenItem
