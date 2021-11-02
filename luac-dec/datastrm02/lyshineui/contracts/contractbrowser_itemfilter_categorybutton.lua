local ContractBrowser_ItemFilter_CategoryButton = {
  Properties = {
    IconImage = {
      default = EntityId()
    },
    IconImageSelected = {
      default = EntityId()
    },
    SubCategoryHeader = {
      default = EntityId()
    },
    HoverGlow = {
      default = EntityId()
    },
    Hash = {
      default = EntityId()
    },
    EnableHoverTitle = {default = false},
    HoverTitleHolder = {
      default = EntityId()
    },
    HoverTitleText = {
      default = EntityId()
    }
  },
  iconName = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_ItemFilter_CategoryButton)
function ContractBrowser_ItemFilter_CategoryButton:OnInit()
  BaseElement.OnInit(self)
end
function ContractBrowser_ItemFilter_CategoryButton:OnShutdown()
end
function ContractBrowser_ItemFilter_CategoryButton:SetImage(imagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.IconImage, imagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.IconImageSelected, imagePath)
end
function ContractBrowser_ItemFilter_CategoryButton:SetIconName(value)
  self.iconName = value
  if self.Properties.EnableHoverTitle then
    self:SetHoverTitleText(value)
  end
end
function ContractBrowser_ItemFilter_CategoryButton:SetHoverTitleText(value)
  local locTag = string.lower("@ui_" .. value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.HoverTitleText, locTag, eUiTextSet_SetLocalized)
end
function ContractBrowser_ItemFilter_CategoryButton:GetIconName()
  return self.iconName
end
function ContractBrowser_ItemFilter_CategoryButton:SetCallback(callerTable, callerFn, key)
  self.callerTable = callerTable
  self.callerFn = callerFn
  self.key = key
end
function ContractBrowser_ItemFilter_CategoryButton:ExecuteCallback()
  if self.callerTable then
    self.callerFn(self.callerTable, self.key)
  end
end
function ContractBrowser_ItemFilter_CategoryButton:SetVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, isVisible and 72 or 0)
end
function ContractBrowser_ItemFilter_CategoryButton:OnFocus()
  if self.Properties.EnableHoverTitle then
    local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.HoverTitleText)
    local horizontalPadding = 20
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.HoverTitleHolder, textWidth + horizontalPadding)
    self.ScriptedEntityTweener:Play(self.Properties.HoverTitleHolder, 0.3, {x = 86, opacity = 0}, {
      x = 96,
      opacity = 1,
      ease = "QuadOut"
    })
  end
  UiElementBus.Event.SetIsEnabled(self.HoverGlow, true)
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.2})
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.6})
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.6,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.HoverGlow, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.6, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HoverGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.6,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  UiElementBus.Event.SetIsEnabled(self.Hash, true)
  self.ScriptedEntityTweener:Play(self.Hash, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Hover)
end
function ContractBrowser_ItemFilter_CategoryButton:OnUnfocus()
  if self.Properties.EnableHoverTitle then
    self.ScriptedEntityTweener:Play(self.Properties.HoverTitleHolder, 0.2, {
      x = 86,
      opacity = 0,
      ease = "QuadOut"
    })
  end
  self.ScriptedEntityTweener:Play(self.HoverGlow, 0.2, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Hash, 0.05, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
function ContractBrowser_ItemFilter_CategoryButton:OnPress()
  self.audioHelper:PlaySound(self.audioHelper.Contracts_Category_Tab_Select)
end
function ContractBrowser_ItemFilter_CategoryButton:AddToGroup(groupEntityId)
  if groupEntityId then
    UiRadioButtonGroupBus.Event.AddRadioButton(groupEntityId, self.entityId)
  end
end
function ContractBrowser_ItemFilter_CategoryButton:OnChange()
end
function ContractBrowser_ItemFilter_CategoryButton:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return ContractBrowser_ItemFilter_CategoryButton
