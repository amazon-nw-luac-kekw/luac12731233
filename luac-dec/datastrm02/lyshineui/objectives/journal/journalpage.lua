local JournalPage = {
  Properties = {
    Title = {
      default = EntityId()
    },
    Subtitle = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    Body = {
      default = EntityId()
    },
    PageNumber = {
      default = EntityId()
    },
    DiscoveredPane = {
      default = EntityId()
    },
    UndiscoveredPane = {
      default = EntityId()
    },
    UndiscoveredText = {
      default = EntityId()
    },
    ScrollBar = {
      default = EntityId()
    }
  },
  userData = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(JournalPage)
function JournalPage:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiMarkupButtonNotificationsBus, self.Properties.Body)
  self:BusConnect(UiMarkupButtonNotificationsBus, self.Properties.PageNumber)
  UiMarkupButtonBus.Event.SetLinkColor(self.Properties.Body, self.UIStyle.COLOR_TEXT_LINK)
  UiMarkupButtonBus.Event.SetLinkColor(self.Properties.PageNumber, self.UIStyle.COLOR_TEXT_LINK)
  UiMarkupButtonBus.Event.SetLinkHoverColor(self.Properties.Body, self.UIStyle.COLOR_TEXT_LINK_HOVER)
  UiMarkupButtonBus.Event.SetLinkHoverColor(self.Properties.PageNumber, self.UIStyle.COLOR_TEXT_LINK_HOVER)
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_JOURNAL_PAGE_TITLE)
  SetTextStyle(self.Properties.Subtitle, self.UIStyle.FONT_STYLE_JOURNAL_PAGE_SUBTITLE)
  SetTextStyle(self.Properties.Body, self.UIStyle.FONT_STYLE_JOURNAL_BODY)
  SetTextStyle(self.Properties.PageNumber, self.UIStyle.FONT_STYLE_JOURNAL_BODY)
  SetTextStyle(self.Properties.UndiscoveredText, self.UIStyle.FONT_STYLE_JOURNAL_UNDISCOVERED)
end
function JournalPage:SetUserData(userData)
  self.userData = userData
  UiElementBus.Event.SetIsEnabled(self.Properties.DiscoveredPane, not self.userData.locked)
  UiElementBus.Event.SetIsEnabled(self.Properties.UndiscoveredPane, self.userData.locked)
  if not self.userData.locked then
    self:SetTitle(tostring(self.userData.title))
    self:SetBody(tostring(self.userData.body))
    self:SetSubtitle(self.userData.subtitle)
    self:SetImage(self.userData.imagePath)
    self:SetPageNumber(self.userData.data.order, self.userData.locationName, self.userData.location and tostring(self.userData.location.x) .. "," .. tostring(self.userData.location.y))
  end
end
function JournalPage:SetActive(active)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ScrollBar, active)
end
function JournalPage:GetUserData(userData)
  return self.userData
end
function JournalPage:SetTitle(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, text, eUiTextSet_SetLocalized)
end
function JournalPage:SetSubtitle(text)
  text = text or ""
  UiTextBus.Event.SetTextWithFlags(self.Properties.Subtitle, text, eUiTextSet_SetLocalized)
  self.ScriptedEntityTweener:Set(self.Properties.Title, {
    y = text == "" and 39 or 0
  })
end
function JournalPage:SetImage(imagePath)
  if imagePath == nil then
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Image, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.Image, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Image, true)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Image, 395)
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, imagePath)
  end
end
function JournalPage:SetBody(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Body, text, eUiTextSet_SetLocalized)
end
function JournalPage:SetScroll(scrollY)
  scrollY = scrollY or 0
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.DiscoveredPane, scrollY)
end
function JournalPage:SetPageNumber(number, locationName, locationXY)
  local replacements = {number = number}
  local locString = "@journal_page_number"
  if locationName ~= nil then
    locString = "@journal_page_number_location"
    if locationXY ~= nil then
      replacements.location = "<a action=\"OpenMap\" data=\"" .. locationXY .. "\">" .. locationName .. "</a>"
    else
      replacements.location = locationName
    end
  end
  local pageNumberText = GetLocalizedReplacementText(locString, replacements)
  UiTextBus.Event.SetText(self.Properties.PageNumber, pageNumberText)
end
function JournalPage:SetScrollBarVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.ScrollBar, isVisible)
end
function JournalPage:ShowScrollBar(shouldShow)
  if shouldShow then
    self.ScriptedEntityTweener:Play(self.Properties.ScrollBar, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.ScrollBar, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function JournalPage:OnPressed(markupId, actionName, data)
  if self.documentTabEntity and type(self.documentTabEntity[actionName]) == "function" then
    self.documentTabEntity[actionName](self.documentTabEntity, data)
  else
    local coords = StringSplit(data, ",")
    if 2 <= #coords then
      local position = Vector3(tonumber(coords[1]), tonumber(coords[2]), 0)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.OpenMapPosition", position)
      local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
      LyShineManagerBus.Broadcast.OnAction(canvasId, self.entityId, "ancestor:" .. actionName)
    end
  end
end
function JournalPage:SetDocumentTabEntity(documentTabEntityTable)
  self.documentTabEntity = documentTabEntityTable
end
return JournalPage
