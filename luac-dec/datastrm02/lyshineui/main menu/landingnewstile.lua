local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local LandingNewsTile = {
  Properties = {
    Title = {
      default = EntityId()
    },
    TitleDarken = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    VideoPlayerIcon = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    PriceInfoHolder = {
      default = EntityId()
    },
    PriceDescription = {
      default = EntityId()
    },
    Price = {
      default = EntityId()
    },
    PriceOld = {
      default = EntityId()
    },
    TimeRemaining = {
      default = EntityId()
    },
    Focus = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    DropShadow = {
      default = EntityId()
    }
  },
  isDataSet = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(LandingNewsTile)
function LandingNewsTile:OnInit()
  BaseElement.OnInit(self)
  self.focusColor = self.UIStyle.COLOR_WHITE
  self.unfocusColor = self.UIStyle.COLOR_GRAY_70
  self.Frame:SetFrameTextureVisible(false)
  self.Frame:SetLineVisible(true)
  self.Frame:SetFillAlpha(0)
  self:OnUnFocus()
end
function LandingNewsTile:OnShutdown()
  UiImageBus.Event.UnloadTexture(self.Properties.Image)
end
function LandingNewsTile:SetNewsData(newsData)
  self.isDataSet = true
  local title = newsData.title and newsData.title or ""
  local description = newsData.description and newsData.description or ""
  local price = newsData.price and newsData.price or ""
  local oldPrice = newsData.oldPrice and newsData.oldPrice or ""
  UiTextBus.Event.SetText(self.Properties.Title, title)
  UiTextBus.Event.SetText(self.Properties.Description, description)
  UiTextBus.Event.SetText(self.Properties.Price, price)
  UiTextBus.Event.SetText(self.Properties.PriceDescription, description)
  UiTextBus.Event.SetText(self.Properties.PriceOld, oldPrice)
  self:SetTitleDarkenWidth()
  local timeText = ""
  if newsData.timeRemainingSeconds and newsData.timeRemainingSeconds > 0 then
    timeText = timeHelpers:ConvertToLargestTimeEstimate(newsData.timeRemainingSeconds, true)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.TimeRemaining, timeText, eUiTextSet_SetLocalized)
  local isPriceInfoShowing = price ~= ""
  UiElementBus.Event.SetIsEnabled(self.Properties.PriceInfoHolder, isPriceInfoShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.Description, not isPriceInfoShowing)
  UiMainMenuRequestBus.Broadcast.SetImageComponentByMarketingTileIndex(self.Properties.Image, newsData.index)
  UiElementBus.Event.SetIsEnabled(self.Properties.VideoPlayerIcon, newsData.isVideo)
  self.urlIndex = newsData.index
end
function LandingNewsTile:SetImage(value)
  UiImageBus.Event.SetSpritePathname(self.Properties.Image, value)
end
function LandingNewsTile:SetText(title, description)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, title, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Description, description, eUiTextSet_SetLocalized)
  self:SetTitleDarkenWidth()
end
function LandingNewsTile:SetTitleDarkenWidth()
  local text = UiTextBus.Event.GetText(self.Properties.Title)
  if text ~= "" then
    local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.Title)
    local textPadding = 35
    UiElementBus.Event.SetIsEnabled(self.Properties.TitleDarken, true)
    self.ScriptedEntityTweener:Set(self.Properties.TitleDarken, {
      w = textWidth + textPadding
    })
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TitleDarken, false)
  end
end
function LandingNewsTile:OnFocus()
  local animDuration = 0.3
  self.ScriptedEntityTweener:Play(self.Properties.Title, animDuration, {
    textColor = self.focusColor,
    ease = "QaudOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Description, animDuration, {
    textColor = self.focusColor,
    ease = "QaudOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.PriceDescription, animDuration, {
    textColor = self.focusColor,
    ease = "QaudOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Focus, animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.DropShadow, animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.entityId, animDuration, {
    scaleX = 1.02,
    scaleY = 1.02,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function LandingNewsTile:OnUnFocus()
  local animDuration = 0.2
  self.ScriptedEntityTweener:Play(self.Properties.Title, animDuration, {
    textColor = self.unfocusColor,
    ease = "QaudIn"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Description, animDuration, {
    textColor = self.unfocusColor,
    ease = "QaudIn"
  })
  self.ScriptedEntityTweener:Play(self.Properties.PriceDescription, animDuration, {
    textColor = self.unfocusColor,
    ease = "QaudIn"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Focus, animDuration, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.DropShadow, animDuration, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.entityId, animDuration, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
end
function LandingNewsTile:OnPress()
  self:OnUnFocus()
  if self.isDataSet then
    UiMainMenuRequestBus.Broadcast.OpenMarketingTileUrlByIndex(self.urlIndex)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return LandingNewsTile
