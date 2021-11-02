local ListItembg = {
  Properties = {
    ItemBg = {
      default = EntityId()
    },
    ItemHighlight = {
      default = EntityId()
    },
    FocusGlow = {
      default = EntityId()
    },
    HoverGlow = {
      default = EntityId()
    }
  },
  LIST_ITEM_STYLE_DEFAULT = 1,
  LIST_ITEM_STYLE_ZEBRA = 2,
  listItemStyle = 1,
  width = nil,
  height = nil,
  index = nil,
  animDuration = 0.3
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ListItembg)
function ListItembg:OnInit()
  BaseElement.OnInit(self)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.width, self.height)
  self:SetListItemStyle(self.LIST_ITEM_STYLE_DEFAULT)
end
function ListItembg:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function ListItembg:SetListItemStyle(style)
  self.listItemStyle = style
  if self.listItemStyle == self.LIST_ITEM_STYLE_DEFAULT then
    self.ScriptedEntityTweener:Set(self.Properties.ItemBg, {opacity = 1})
  elseif self.listItemStyle == self.LIST_ITEM_STYLE_ZEBRA then
    self.ScriptedEntityTweener:Set(self.Properties.ItemBg, {opacity = 0})
    if self.index ~= nil then
      if self.index % 2 ~= 0 then
        self.ScriptedEntityTweener:Set(self.Properties.ItemHighlight, {
          opacity = self.zebraOpacity or 0.4
        })
      else
        self.ScriptedEntityTweener:Set(self.Properties.ItemHighlight, {opacity = 0.1})
      end
    end
  end
end
function ListItembg:SetIndex(index)
  self.index = index
end
function ListItembg:GetIndex()
  return self.index
end
function ListItembg:SetFocusGlowEnabled(isEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.FocusGlow, isEnabled)
end
function ListItembg:GetFocusGlowEnabled()
  return UiElementBus.Event.IsEnabled(self.Properties.FocusGlow)
end
function ListItembg:SetZebraOpacity(opacity)
  self.zebraOpacity = opacity
end
function ListItembg:GetZebraOpacity()
  return self.zebraOpacity
end
function ListItembg:GetWidth()
  return self.width
end
function ListItembg:GetHeight()
  return self.height
end
function ListItembg:SetBgImage(imagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemBg, imagePath)
  self.ScriptedEntityTweener:Set(self.Properties.ItemBg, {opacity = 1})
end
function ListItembg:OnFocus(useGlow)
  local opacityGlow = useGlow and 0.45 or 0
  self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, self.animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HoverGlow, self.animDuration, {opacity = opacityGlow, ease = "QuadOut"})
end
function ListItembg:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, self.animDuration, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HoverGlow, self.animDuration, {opacity = 0, ease = "QuadOut"})
end
function ListItembg:OnShutdown()
end
return ListItembg
