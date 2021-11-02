local JournalTopic = {
  Properties = {
    ContentXWithImage = {default = 165},
    Frame = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    StatsContainer = {
      default = EntityId()
    },
    DiscoveredCount = {
      default = EntityId()
    },
    DiscoveredCountLabel = {
      default = EntityId()
    },
    CompletedCount = {
      default = EntityId()
    },
    CompletedCountLabel = {
      default = EntityId()
    },
    PagesCount = {
      default = EntityId()
    },
    PagesCountLabel = {
      default = EntityId()
    },
    UnreadBadge = {
      default = EntityId()
    }
  },
  userData = nil,
  unreadNumber = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(JournalTopic)
function JournalTopic:OnInit()
  BaseElement.OnInit(self)
  local titleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 39,
    characterSpacing = 100,
    fontColor = self.UIStyle.COLOR_TAN
  }
  SetTextStyle(self.Properties.Title, titleStyle)
  local bodyStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 26,
    fontColor = self.UIStyle.COLOR_GRAY_80,
    characterSpacing = 25
  }
  SetTextStyle(self.Properties.Description, bodyStyle)
  local labelStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 23,
    fontColor = self.UIStyle.COLOR_GRAY_80,
    characterSpacing = 25
  }
  SetTextStyle(self.Properties.DiscoveredCountLabel, labelStyle)
  SetTextStyle(self.Properties.CompletedCountLabel, labelStyle)
  SetTextStyle(self.Properties.PagesCountLabel, labelStyle)
  local statStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 40,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.Properties.DiscoveredCount, statStyle)
  SetTextStyle(self.Properties.CompletedCount, statStyle)
  SetTextStyle(self.Properties.PagesCount, statStyle)
end
function JournalTopic:OnShutdown()
  if self.highlightTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.highlightTimeline)
  end
end
function JournalTopic:SetUserData(userData)
  self.userData = userData
  UiTextBus.Event.SetText(self.Properties.DiscoveredCount, self.userData.visibleChapterCount or 0)
  UiTextBus.Event.SetText(self.Properties.CompletedCount, self.userData.completedChapterCount or 0)
  UiTextBus.Event.SetText(self.Properties.PagesCount, self.userData.unlockedPageCount or 0)
  if self.userData.imagePath then
    self.hasImage = true
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, self.userData.imagePath)
  else
    self.hasImage = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Image, self.hasImage)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.Content, self.hasImage and self.Properties.ContentXWithImage or 0)
  self:SetTitle(self.userData.title)
  self:SetDescription(self.userData.body)
  self:SetUnreadNumber(self.userData.newPageCount or 0)
end
function JournalTopic:GetUserData(userData)
  return self.userData
end
function JournalTopic:SetTitle(title)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, title, eUiTextSet_SetLocalized)
end
function JournalTopic:SetDescription(description)
  local descriptionHeight = 0
  if description ~= nil then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Description, description, eUiTextSet_SetLocalized)
    descriptionHeight = UiTextBus.Event.GetTextHeight(self.Properties.Description)
  else
    UiTextBus.Event.SetText(self.Properties.Description, "")
  end
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Description, descriptionHeight)
end
function JournalTopic:OnHoverStart()
  if not self.highlightTimeline then
    self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.3})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.4})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.4,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.4, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.4,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
  local animTime = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.Properties.Frame, animTime, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Title, animTime, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  if self.hasImage then
    self.ScriptedEntityTweener:Play(self.Properties.Image, animTime, {opacity = 1, ease = "QuadOut"})
  end
  self.audioHelper:PlaySound(self.audioHelper.Lore_HoverTopic)
end
function JournalTopic:OnHoverStop()
  if self.highlightTimeline then
    self.highlightTimeline:Stop()
  end
  local animTime = self.UIStyle.DURATION_BUTTON_FADE_OUT
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, animTime, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Frame, animTime, {opacity = 0.5, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Title, animTime, {
    textColor = self.UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
  if self.hasImage then
    self.ScriptedEntityTweener:Play(self.Properties.Image, animTime, {opacity = 0.6, ease = "QuadOut"})
  end
end
function JournalTopic:ChangeTopic()
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  LyShineManagerBus.Broadcast.OnAction(canvasId, self.entityId, "ancestor:OnChangeTopic")
end
function JournalTopic:SetUnreadNumber(number)
  if 0 < number then
    UiElementBus.Event.SetIsEnabled(self.Properties.UnreadBadge, true)
    self.UnreadBadge:SetNumber(number)
    if self.isVisible then
      self.UnreadBadge:StartAnimation(true)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.UnreadBadge, false)
    self.UnreadBadge:StopAnimation()
  end
  self.unreadNumber = number
end
function JournalTopic:SetIsVisible(isVisible)
  if isVisible == self.isVisible then
    return
  end
  if isVisible and self.unreadNumber > 0 then
    self.UnreadBadge:StartAnimation(true)
  else
    self.UnreadBadge:StopAnimation()
  end
  self.isVisible = isVisible
end
return JournalTopic
