local WarDeclarationPopupCampItem = {
  Properties = {
    Title = {
      default = EntityId()
    },
    Label1 = {
      default = EntityId()
    },
    Label2 = {
      default = EntityId()
    },
    Data1 = {
      default = EntityId()
    },
    Data2 = {
      default = EntityId()
    },
    Cost = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    }
  },
  itemData = nil,
  callback = nil,
  callbackTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WarDeclarationPopupCampItem)
function WarDeclarationPopupCampItem:OnInit()
  BaseElement.OnInit(self)
  if not self.pulseTimeline then
    self.pulseTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.pulseTimeline:Add(self.Properties.Highlight, 0.35, {opacity = 0.9})
    self.pulseTimeline:Add(self.Properties.Highlight, 0.05, {opacity = 0.9})
    self.pulseTimeline:Add(self.Properties.Highlight, 0.3, {
      opacity = 0.4,
      onComplete = function()
        self.pulseTimeline:Play()
      end
    })
  end
end
function WarDeclarationPopupCampItem:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function WarDeclarationPopupCampItem:SetData(value)
  self.itemData = value
  if self.itemData then
    local titleText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_structureinfo_tier", self.itemData.campId + 1)
    UiTextBus.Event.SetText(self.Properties.Title, titleText)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Label1, "@ui_wardeclarationpopup_item_deployment_limit", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Label2, "@ui_wardeclarationpopup_item_siege_supply_rate", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Data1, self.itemData.deploymentLimit, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Data2, self.itemData.siegeSupplyRate, eUiTextSet_SetLocalized)
    if self.itemData.cost then
      self:SetWarCampCost(self.itemData.cost)
    end
  end
end
function WarDeclarationPopupCampItem:GetData()
  return self.itemData
end
function WarDeclarationPopupCampItem:SetWarCampCost(value)
  self.itemData.cost = value
  UiTextBus.Event.SetTextWithFlags(self.Properties.Cost, GetLocalizedCurrency(self.itemData.cost), eUiTextSet_SetLocalized)
end
function WarDeclarationPopupCampItem:GetWarCampCost()
  return self.itemData.cost
end
function WarDeclarationPopupCampItem:OnFocus()
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    scaleX = 1.04,
    scaleY = 1.04,
    ease = "QuadOut"
  })
  self.pulseTimeline:Play()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function WarDeclarationPopupCampItem:OnUnfocus()
  local toggleState = UiRadioButtonBus.Event.GetState(self.entityId)
  if toggleState then
    self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.15, {opacity = 1, ease = "QuadOut"})
    return
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.15, {opacity = 0, ease = "QuadOut"})
end
function WarDeclarationPopupCampItem:OnPress()
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    scaleX = 1,
    scaleY = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.15, {opacity = 1, ease = "QuadOut"})
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable, self.itemData)
  end
end
function WarDeclarationPopupCampItem:OnShutdown()
  if self.pulseTimeline then
    self.pulseTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.pulseTimeline)
  end
end
return WarDeclarationPopupCampItem
