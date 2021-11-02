local TurretListItem = {
  Properties = {
    ItemName = {
      default = EntityId()
    },
    ItemTier = {
      default = EntityId()
    },
    ItemImage = {
      default = EntityId()
    },
    ItemHighlight = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TurretListItem)
function TurretListItem:OnInit()
  BaseElement:OnInit(self)
  if not self.pulseTimeline then
    self.pulseTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.pulseTimeline:Add(self.Properties.ItemHighlight, 0.35, {opacity = 0.9})
    self.pulseTimeline:Add(self.Properties.ItemHighlight, 0.05, {opacity = 0.9})
    self.pulseTimeline:Add(self.Properties.ItemHighlight, 0.3, {
      opacity = 0.4,
      onComplete = function()
        self.pulseTimeline:Play()
      end
    })
  end
  local itemNameTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_TAN
  }
  local itemTierTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 16,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.ItemName, itemNameTextStyle)
  SetTextStyle(self.ItemTier, itemTierTextStyle)
end
function TurretListItem:SetEnabled(enabled)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, enabled)
end
function TurretListItem:SetItem(name, image, tierLevel, turretType)
  local imagePath = image .. tierLevel .. ".dds"
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, name, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemImage, imagePath)
  local tierText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_structureinfo_tier", GetRomanFromNumber(tierLevel))
  UiTextBus.Event.SetText(self.Properties.ItemTier, tierText)
  self.turretType = turretType
end
function TurretListItem:SetCallback(callback, callingTable)
  self.callbackFunction = callback
  self.callbackTable = callingTable
end
function TurretListItem:OnFocus()
  self.ScriptedEntityTweener:Play(self.entityId, 0.12, {
    scaleX = 1.03,
    scaleY = 1.03,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemImage, 0.12, {
    scaleX = 1.05,
    scaleY = 1.05,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemName, 0.3, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.pulseTimeline:Play()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function TurretListItem:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.entityId, 0.12, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemImage, 0.12, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, 0.12, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ItemName, 0.3, {
    textColor = self.UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
end
function TurretListItem:OnPress(entityId)
  if self.callbackFunction ~= nil and self.callbackTable ~= nil and type(self.callbackFunction) == "function" then
    self.callbackFunction(self.callbackTable, self.turretType)
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
function TurretListItem:OnShutdown()
  if self.pulseTimeline then
    self.pulseTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.pulseTimeline)
  end
end
return TurretListItem
