local ContactLinks = {
  Properties = {
    Button1 = {
      default = EntityId()
    },
    Button2 = {
      default = EntityId()
    },
    Button3 = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContactLinks)
function ContactLinks:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.Button3, false)
  self.supportOptions = {
    {
      entityTable = self.Button1,
      text = "@ui_escapemenu_submit_feedback",
      description = "@ui_navmenu_submit_feedback_desc",
      callback = "OnSubmitFeedbackPressed"
    },
    {
      entityTable = self.Button2,
      text = "@ui_navmenu_get_help",
      description = "@ui_navmenu_get_help_desc",
      callback = "OnHelpPressed"
    }
  }
  for _, supportOptionData in ipairs(self.supportOptions) do
    local optionButtonTable = supportOptionData.entityTable
    if optionButtonTable and type(optionButtonTable) == "table" then
      SetTextStyle(optionButtonTable.Properties.ButtonText, self.UIStyle.FONT_STYLE_TITLE_GENERIC_SMALL)
      UiTextBus.Event.SetTextWithFlags(optionButtonTable.Properties.ButtonText, supportOptionData.text, eUiTextSet_SetLocalized)
      local descText = UiElementBus.Event.FindDescendantByName(optionButtonTable.entityId, "DescText")
      UiTextBus.Event.SetTextWithFlags(descText, supportOptionData.description, eUiTextSet_SetLocalized)
      optionButtonTable:SetCallback(supportOptionData.callback, self)
    end
  end
end
function ContactLinks:RemoveFeedbackButton()
  UiElementBus.Event.DestroyElement(self.supportOptions[1].entityTable.entityId)
end
function ContactLinks:SetVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible then
    self.cursorNotificationBus = self:BusConnect(CursorNotificationBus)
  elseif self.cursorNotificationBus then
    self:BusDisconnect(self.cursorNotificationBus)
    self.cursorNotificationBus = nil
  end
end
function ContactLinks:OnSubmitFeedbackPressed()
  LyShineDataLayerBus.Broadcast.SetData("UserFeedback.InvokedFrom", "@ui_feedback_general")
  self:SetVisible(false)
end
function ContactLinks:OnHelpPressed()
  OptionsDataBus.Broadcast.OpenHelpInBrowser()
  self:SetVisible(false)
end
function ContactLinks:OnCursorPressed()
  if not IsCursorOverUiEntity(self.entityId, 15) then
    self:SetVisible(false)
  end
end
function ContactLinks:OnShutdown()
end
return ContactLinks
