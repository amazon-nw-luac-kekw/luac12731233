local TownProject_CompleteAllMissionsPopup = {
  Properties = {
    Information = {
      default = EntityId()
    },
    TurnInList = {
      default = EntityId()
    },
    GoldReward = {
      default = EntityId()
    },
    XP = {
      default = EntityId()
    },
    TerritoryStanding = {
      default = EntityId()
    },
    CompleteAllButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TownProject_CompleteAllMissionsPopup)
function TownProject_CompleteAllMissionsPopup:OnInit()
  BaseElement.OnInit(self)
  self.CompleteAllButton:SetCallback(self.OnCompleteAll, self)
  self.CancelButton:SetCallback(self.OnCancel, self)
  self.CompleteAllButton:SetButtonStyle(self.CompleteAllButton.BUTTON_STYLE_CTA)
end
function TownProject_CompleteAllMissionsPopup:ShowCompleteAllMissionsPopup(info, callback, caller)
  self.callback = callback
  self.caller = caller
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  local text = GetLocalizedReplacementText("@ui_you_have_n_completed_missions", {
    count = info.missionCount
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.Information, text, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GoldReward, info.gold, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.XP, GetLocalizedNumber(info.xp), eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryStanding, GetLocalizedNumber(info.territoryStanding), eUiTextSet_SetAsIs)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.TurnInList, #info.turnIns)
  local children = UiElementBus.Event.GetChildren(self.Properties.TurnInList)
  for i, turnIn in ipairs(info.turnIns) do
    local bg = children[i]
    local Icon = UiElementBus.Event.GetChild(bg, 0)
    local textElement = UiElementBus.Event.GetChild(bg, 1)
    UiImageBus.Event.SetSpritePathname(Icon, turnIn.spritePath)
    UiTextBus.Event.SetTextWithFlags(textElement, tostring(turnIn.count), eUiTextSet_SetAsIs)
  end
end
function TownProject_CompleteAllMissionsPopup:OnShutdown()
end
function TownProject_CompleteAllMissionsPopup:Close(completeAll)
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 1, y = 0}, {
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
  if self.callback then
    self.callback(self.caller, completeAll)
  end
end
function TownProject_CompleteAllMissionsPopup:OnCompleteAll()
  self:Close(true)
end
function TownProject_CompleteAllMissionsPopup:OnCancel()
  self:Close(false)
end
return TownProject_CompleteAllMissionsPopup
