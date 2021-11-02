local RenamePopup = {
  Properties = {
    RenameMessage = {
      default = EntityId()
    },
    NameInputField = {
      default = EntityId()
    },
    ButtonHolderOk = {
      default = EntityId()
    },
    ButtonOk = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    }
  },
  characterId = "",
  characterName = ""
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(RenamePopup)
function RenamePopup:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(UiMainMenuBus)
  DynamicBus.RenamePopupBus.Connect(self.entityId, self)
  SetTextStyle(self.RenameMessage, self.UIStyle.FONT_STYLE_BODY_NEW)
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.FrameHeader:SetText("@ui_rename_character")
  self.ButtonOk:SetText("@ui_confirm")
  self.ButtonOk:SetButtonStyle(self.ButtonOk.BUTTON_STYLE_CTA)
  self.ButtonOk:SetEnabled(false)
  self.ButtonOk:SetCallback("OnSubmit", self)
  self.ButtonClose:SetCallback(function()
    self:OpenPopup(false)
    self:ExecuteCallback()
  end, self)
end
function RenamePopup:OpenPopup(open, currentName, currentCharacterId)
  if open then
    self.currentName = currentName
    self.currentCharacterId = currentCharacterId
    local description = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_rename_required", self.currentName)
    UiTextBus.Event.SetTextWithFlags(self.Properties.RenameMessage, description, eUiTextSet_SetAsIs)
    LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
  else
    LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
  end
end
function RenamePopup:OnTransitionIn(stateName, levelName, toState, toLevel)
  self.ScriptedEntityTweener:Play(self.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.7, ease = "QuadOut"})
  self.NameInputField:OnShow(true)
end
function RenamePopup:OnTransitionOut(stateName, levelName, toState, toLevel)
  self.NameInputField:OnShow(false)
end
function RenamePopup:EditPlayerName()
  self.NameInputField:EditPlayerName()
end
function RenamePopup:SetCallback(callbackName, callbackTable)
  self.callbackName = callbackName
  self.callbackTable = callbackTable
end
function RenamePopup:OnShutdown()
  DynamicBus.RenamePopupBus.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
end
function RenamePopup:OnSubmit()
  UiMainMenuRequestBus.Broadcast.RenameCharacter(self.currentCharacterId, self.NameInputField.validatedName)
end
function RenamePopup:RenameCharacterResult(success, errorCode, errorMessage)
  if not success then
    UiPopupBus.Broadcast.ShowPopup(ePopupButtons_OK, errorCode, errorMessage, "Popup_ErrorMessage")
  end
  self:ExecuteCallback()
  self:OpenPopup(false)
end
function RenamePopup:ExecuteCallback()
  if self.callbackTable and self.callbackName then
    self.callbackTable[self.callbackName](self.callbackTable)
  end
end
return RenamePopup
