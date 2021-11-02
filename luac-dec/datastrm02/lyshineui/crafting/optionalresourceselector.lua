local OptionalResourceSelector = {
  Properties = {
    FrameMultiBg = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    RadioGroup = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    ButtonAccept = {
      default = EntityId()
    }
  },
  callbackFunction = nil,
  callbackTable = nil,
  closeCallbackFunction = nil,
  closeCallbackTable = nil,
  NUM_UPGRADE_STEPS = 5
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OptionalResourceSelector)
function OptionalResourceSelector:OnInit()
  BaseElement:OnInit(self)
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
  self.ButtonClose:SetCallback(self.OnClose, self)
  self.ButtonAccept:SetText("@ui_accept")
  self.ButtonAccept:SetCallback(self.OnSelected, self)
  self.ButtonAccept:SetButtonStyle(self.ButtonAccept.BUTTON_STYLE_CTA)
  self.FrameHeader:SetTextMarkupEnabled(true)
  self.FrameHeader:SetTextShrinkToFit(eUiTextShrinkToFit_None)
  self.FrameHeader:SetText("@crafting_azothselectiontitle")
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
end
function OptionalResourceSelector:Show()
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut"
  })
end
function OptionalResourceSelector:Hide()
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end
  })
end
function OptionalResourceSelector:SetupPopup(itemId, perkCost, currentAmount, selectedOption, selectedType, max)
  self.itemId = itemId
  self.selectedOption = selectedOption
  self.selectedPerkItemType = selectedType
  self.maximumPerks = max
  for i = 0, self.NUM_UPGRADE_STEPS do
    local child = UiElementBus.Event.GetChild(self.Properties.RadioGroup, i)
    local option = self.registrar:GetEntityTable(child)
    local stepCost = i * perkCost
    option:SetPrimaryText(tostring(stepCost))
    option:SetCallback(self.HandleSelection, self, i)
    option:SetEnabled((i == 0 or currentAmount >= stepCost) and i <= max)
    option:SetSelected(i == selectedOption)
    local tooltipMessage = "@crafting_azothbonus_not_enough"
    if max < i then
      tooltipMessage = "@crafting_azothbonus_max"
    end
    option:SetSimpleTooltip(tooltipMessage)
  end
  self:UpdateHint()
end
function OptionalResourceSelector:UpdateHint()
  local descText = "@crafting_azothbonus_0"
  if self.selectedOption > 0 then
    local statReplacements = {}
    local replacementIndex = 1
    local perkIndex = 1
    local firstGeneratedPerk = true
    for i = 1, self.NUM_UPGRADE_STEPS do
      local perkBucketType = ItemDataManagerBus.Broadcast.GetPerkBucketType(self.itemId, i)
      if perkBucketType == ePerkType_Inherent and self.selectedPerkItemType ~= ePerkType_Inherent then
        statReplacements["perk" .. tostring(replacementIndex)] = "@crafting_azothbonus_attribute"
        replacementIndex = replacementIndex + 1
      elseif perkBucketType == ePerkType_Gem and self.selectedPerkItemType ~= ePerkType_Gem then
        statReplacements["perk" .. tostring(replacementIndex)] = "@crafting_azothbonus_gemslot"
        replacementIndex = replacementIndex + 1
      elseif perkBucketType == ePerkType_Generated then
        if self.selectedPerkItemType == ePerkType_Generated and firstGeneratedPerk then
          firstGeneratedPerk = false
          perkIndex = perkIndex + 1
        else
          statReplacements["perk" .. tostring(replacementIndex)] = "@crafting_azothbonus_perk" .. tostring(perkIndex)
          replacementIndex = replacementIndex + 1
          perkIndex = perkIndex + 1
        end
      end
    end
    descText = GetLocalizedReplacementText("@crafting_azothbonus_" .. tostring(self.selectedOption), statReplacements)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, descText, eUiTextSet_SetLocalized)
end
function OptionalResourceSelector:SetCallback(callback, callingTable)
  self.callbackFunction = callback
  self.callbackTable = callingTable
end
function OptionalResourceSelector:SetCloseCallback(callback, callingTable)
  self.closeCallbackFunction = callback
  self.closeCallbackTable = callingTable
end
function OptionalResourceSelector:OnClose()
  if self.closeCallbackFunction ~= nil and self.closeCallbackTable ~= nil and type(self.closeCallbackFunction) == "function" then
    self.closeCallbackFunction(self.closeCallbackTable, self.selectedOption)
  end
end
function OptionalResourceSelector:OnSelected()
  if self.callbackFunction ~= nil and self.callbackTable ~= nil and type(self.callbackFunction) == "function" then
    self.callbackFunction(self.callbackTable, self.selectedOption)
  end
end
function OptionalResourceSelector:HandleSelection(entityId, value)
  self.selectedOption = value
  self:UpdateHint()
  for i = 0, self.NUM_UPGRADE_STEPS do
    local child = UiElementBus.Event.GetChild(self.Properties.RadioGroup, i)
    local option = self.registrar:GetEntityTable(child)
    option:SetSelectedByValue(self.selectedOption)
  end
end
return OptionalResourceSelector
