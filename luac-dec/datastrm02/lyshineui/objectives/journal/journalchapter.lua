local JournalChapter = {
  Properties = {
    TitleYWithImage = {default = -87},
    TitleYOffsetWithoutImage = {default = -24},
    Title = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    PageGrid = {
      default = EntityId()
    },
    PageCount = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    UnreadBadge = {
      default = EntityId()
    }
  },
  userData = nil,
  hasImage = true,
  unreadNumber = 0,
  PAGE_ICON_PATH_LOCKED = "lyshineui/images/objectives/journal/pageIconLocked.png",
  PAGE_ICON_PATH_UNLOCKED = "lyshineui/images/objectives/journal/pageIconUnlocked.png",
  PAGE_ICON_PATH_NEW = "lyshineui/images/objectives/journal/pageIconNew.png"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(JournalChapter)
function JournalChapter:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, true)
  local titleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 26,
    characterSpacing = 100,
    lineSpacing = -3,
    fontColor = self.UIStyle.COLOR_TAN
  }
  SetTextStyle(self.Title, titleStyle)
  local pageCountStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 23,
    characterSpacing = 0,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.PageCount, pageCountStyle)
end
function JournalChapter:OnShutdown()
  if self.highlightTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.highlightTimeline)
  end
end
function JournalChapter:SetUserData(userData)
  self.userData = userData
  UiDynamicLayoutBus.Event.SetNumChildElements(self.PageGrid, #self.userData.pages)
  local count = 0
  for pageNumber, pageInfo in ipairs(self.userData.pages) do
    local pageIconEntity = UiElementBus.Event.GetChild(self.PageGrid, pageNumber - 1)
    if not pageInfo.locked then
      count = count + 1
      UiImageBus.Event.SetSpritePathname(pageIconEntity, pageInfo.isNew and self.PAGE_ICON_PATH_NEW or self.PAGE_ICON_PATH_UNLOCKED)
    else
      UiImageBus.Event.SetSpritePathname(pageIconEntity, self.PAGE_ICON_PATH_LOCKED)
    end
  end
  local pageCountText = GetLocalizedReplacementText("@journal_page_count", {
    pagesFound = count,
    totalPages = #self.userData.pages
  })
  UiTextBus.Event.SetText(self.Properties.PageCount, pageCountText)
  if self.userData.imagePath then
    self.hasImage = true
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, self.userData.imagePath)
  else
    self.hasImage = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Image, self.hasImage)
  self:SetTitle(self.userData.title)
  self:SetUnreadNumber(self.userData.newPageCount or 0)
end
function JournalChapter:GetUserData(userData)
  return self.userData
end
function JournalChapter:SetTitle(title)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, title, eUiTextSet_SetLocalized)
  if not self.hasImage then
    local cardHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.Title)
    local y = (cardHeight - textHeight) / -2 + self.Properties.TitleYOffsetWithoutImage
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Title, y)
  else
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Title, self.Properties.TitleYWithImage)
  end
end
function JournalChapter:GetChapterId()
  return self.chapterId
end
function JournalChapter:OnHoverStart()
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
  self.audioHelper:PlaySound(self.audioHelper.Lore_HoverChapter)
end
function JournalChapter:OnHoverStop()
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
function JournalChapter:SelectChapter()
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  LyShineManagerBus.Broadcast.OnAction(canvasId, self.entityId, "ancestor:OnSelectChapter")
end
function JournalChapter:SetUnreadNumber(number)
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
function JournalChapter:SetIsVisible(isVisible)
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
return JournalChapter
