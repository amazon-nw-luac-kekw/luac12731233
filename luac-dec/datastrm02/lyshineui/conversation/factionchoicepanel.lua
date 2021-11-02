local FactionChoicePanel = {
  Properties = {
    FactionName = {
      default = EntityId()
    },
    FactionDesc = {
      default = EntityId()
    },
    FactionSubDesc = {
      default = EntityId()
    },
    FactionCrestFg = {
      default = EntityId()
    },
    FactionCrestBg = {
      default = EntityId()
    },
    FactionBg = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    Container = {
      default = EntityId()
    },
    DisabledReasonText = {
      default = EntityId()
    }
  },
  factionSelected = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FactionChoicePanel)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function FactionChoicePanel:OnInit()
  BaseElement.OnInit(self)
  self.factionInfoTable = FactionCommon.factionInfoTable
  self.ScriptedEntityTweener:Set(self.Properties.Highlight, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.Frame, {opacity = 0})
end
function FactionChoicePanel:OnFocus()
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, true)
  self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, 0.3, tweenerCommon.fadeInQuadOut)
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function FactionChoicePanel:OnUnfocus()
  if not self.factionSelected then
    self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, 0.3, tweenerCommon.fadeOutQuadOut)
  end
end
function FactionChoicePanel:OnPress()
  if self.factionSelected then
    return
  end
  self.callback(self.callbackTable, self.factionId)
  self.factionSelected = true
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {scaleX = 1.05, scaleY = 1.05})
  UiElementBus.Event.SetIsEnabled(self.Properties.Frame, true)
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, 0.1, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.2, {
    imgColor = self.factionColor,
    delay = 0.1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, 0.3, tweenerCommon.fadeInQuadOut)
end
function FactionChoicePanel:ClearSelected()
  self.factionSelected = false
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, 0.1, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:Play(self.Properties.Frame, 0, {
    imgColor = self.UIStyle.COLOR_WHITE,
    delay = 0.1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, 0.3, tweenerCommon.fadeOutQuadOut)
end
function FactionChoicePanel:IsSelected()
  return self.factionSelected
end
function FactionChoicePanel:SetupFactionOption(factionId, callback, callbackTable)
  self.factionId = factionId
  self.callback = callback
  self.callbackTable = callbackTable
  local factionName = self.factionInfoTable[self.factionId].factionName
  local factionDesc = self.factionInfoTable[self.factionId].factionDesc
  local factionSubDesc = self.factionInfoTable[self.factionId].factionSubDesc
  local crestFg = self.factionInfoTable[self.factionId].crestFgSmall
  local crestBg = self.factionInfoTable[self.factionId].crestFgSmallOutline
  local crestColorFg = self.factionInfoTable[self.factionId].crestBgColor
  local factionBg = self.factionInfoTable[self.factionId].factionBg
  self.factionColor = self.factionInfoTable[self.factionId].crestBgColor
  UiTextBus.Event.SetTextWithFlags(self.Properties.FactionName, factionName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.FactionDesc, factionDesc, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.FactionSubDesc, factionSubDesc, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.FactionCrestFg, crestFg)
  UiImageBus.Event.SetSpritePathname(self.Properties.FactionCrestBg, crestBg)
  UiImageBus.Event.SetSpritePathname(self.Properties.FactionBg, factionBg)
  UiImageBus.Event.SetColor(self.Properties.FactionCrestFg, crestColorFg)
  UiImageBus.Event.SetColor(self.Properties.FactionCrestBg, self.UIStyle.COLOR_BLACK)
end
function FactionChoicePanel:SetDisabled(reason)
  if reason == eCanSetFactionResults_FactionHasMostTerritory then
    self.ScriptedEntityTweener:Set(self.Properties.Container, {opacity = 0.5})
    UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DisabledReasonText, "@ui_faction_cant_territory", eUiTextSet_SetLocalized)
  else
    self.ScriptedEntityTweener:Set(self.Properties.Container, {opacity = 1})
    UiTextBus.Event.SetText(self.Properties.DisabledReasonText, "")
    UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, true)
  end
end
return FactionChoicePanel
