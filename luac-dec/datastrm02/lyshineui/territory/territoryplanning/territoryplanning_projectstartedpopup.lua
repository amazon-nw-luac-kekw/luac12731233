local TerritoryPlanning_ProjectStartedPopup = {
  Properties = {
    HeaderImage = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    ProjectImage = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_ProjectStartedPopup)
function TerritoryPlanning_ProjectStartedPopup:OnInit()
  BaseElement.OnInit(self)
  self.ButtonClose:SetCallback(self.OnClose, self)
  self.ButtonClose:SetTextStyle(self.UIStyle.FONT_STYLE_CONTRACTS_BUYBUTTON)
  self.ButtonClose:SetText("@ui_back")
end
function TerritoryPlanning_ProjectStartedPopup:OnShutdown()
end
function TerritoryPlanning_ProjectStartedPopup:SetStartedPopupData(upgradeData, closeCallback, closeCallbackSelf)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, upgradeData.projectTitle, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.ProjectImage, upgradeData.projectImage)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  self.audioHelper:PlaySound(self.audioHelper.Banner_TownProjectStart)
  self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_Town_Project_Started)
  self.closeCallback = closeCallback
  self.closeCallbackSelf = closeCallbackSelf
end
function TerritoryPlanning_ProjectStartedPopup:OnClose()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self.IsClosing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  if self.closeCallback then
    self.closeCallback(self.closeCallbackSelf)
  end
end
return TerritoryPlanning_ProjectStartedPopup
