local FrameMultiBg = {
  Properties = {
    FrameBg = {
      default = EntityId()
    },
    FrameTexture = {
      default = EntityId()
    },
    FrameTextureMask = {
      default = EntityId()
    }
  },
  FRAME_STYLE_DEFAULT = 1,
  FRAME_STYLE_DEFAULT_NO_OUTLINE = 2,
  FRAME_STYLE_HORIZONTAL_LIST_COMBO = 3,
  FRAME_STYLE_FULLSCREEN_RIGHT = 4,
  FRAME_STYLE_FULLSCREEN_LEFT = 5,
  FRAME_STYLE_SIDE_PANEL_RIGHT = 6,
  FRAME_STYLE_SIDE_PANEL_LEFT = 7,
  FRAME_STYLE_DEFAULT_PATH = "lyshineui/images/slices/framemultibg/framestyles/FrameBgDefault.dds",
  FRAME_STYLE_DEFAULT_NO_OUTLINE_PATH = "lyshineui/images/slices/framemultibg/framestyles/FrameBgDefaultNoOutline.dds",
  FRAME_STYLE_HORIZONTAL_LIST_COMBO_PATH = "lyshineui/images/slices/framemultibg/framestyles/FrameBgHorizontalListCombo.dds",
  FRAME_STYLE_FULLSCREEN_BG_RIGHT_PATH = "lyshineui/images/slices/framemultibg/framestyles/FrameBgFullscreenRight.dds",
  FRAME_STYLE_SIDE_PANEL_BG_RIGHT_PATH = "lyshineui/images/slices/framemultibg/framestyles/FrameBgSidePanelRight.dds",
  IMAGE_TYPE_STRETCHED = eUiImageType_Stretched,
  IMAGE_TYPE_SLICED = eUiImageType_Sliced,
  IMAGE_TYPE_FIXED = eUiImageType_Fixed,
  IMAGE_TYPE_TILED = eUiImageType_Tiled,
  width = 0,
  height = 0,
  frameOffset = 38
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FrameMultiBg)
function FrameMultiBg:OnInit()
  BaseElement.OnInit(self)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.width, self.height)
  self:SetFrameStyle(self.FRAME_STYLE_DEFAULT)
end
function FrameMultiBg:SetWidth(width)
  self:SetSize(width, self.height)
end
function FrameMultiBg:GetWidth()
  return self.width
end
function FrameMultiBg:SetHeight(height)
  self:SetSize(self.width, height)
end
function FrameMultiBg:GetHeight()
  return self.height
end
function FrameMultiBg:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function FrameMultiBg:SetFrameStyle(style)
  self.frameStyle = style
  if self.frameStyle == self.FRAME_STYLE_DEFAULT then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameBg, self.FRAME_STYLE_DEFAULT_PATH)
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameTextureMask, self.FRAME_STYLE_DEFAULT_PATH)
    self:SetImageType(self.IMAGE_TYPE_SLICED)
    self:SetTextureVisible(true)
    self:SetFillAlpha(0.925)
    self:SetOffsets(-self.frameOffset, -self.frameOffset, self.frameOffset, self.frameOffset)
    UiTransform2dBus.Event.SetOffsets(self.Properties.FrameTextureMask, UiOffsets(-self.frameOffset, -self.frameOffset, self.frameOffset, self.frameOffset))
  elseif self.frameStyle == self.FRAME_STYLE_DEFAULT_NO_OUTLINE then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameBg, self.FRAME_STYLE_DEFAULT_NO_OUTLINE_PATH)
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameTextureMask, self.FRAME_STYLE_DEFAULT_NO_OUTLINE_PATH)
    self:SetImageType(self.IMAGE_TYPE_SLICED)
    self:SetTextureVisible(true)
    self:SetFillAlpha(0.925)
    self:SetOffsets(-self.frameOffset, -self.frameOffset, self.frameOffset, self.frameOffset)
    UiTransform2dBus.Event.SetOffsets(self.Properties.FrameTextureMask, UiOffsets(-self.frameOffset, -self.frameOffset, self.frameOffset, self.frameOffset))
  elseif self.frameStyle == self.FRAME_STYLE_HORIZONTAL_LIST_COMBO then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameBg, self.FRAME_STYLE_HORIZONTAL_LIST_COMBO_PATH)
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameTextureMask, self.FRAME_STYLE_HORIZONTAL_LIST_COMBO_PATH)
    self:SetImageType(self.IMAGE_TYPE_SLICED)
    self:SetTextureVisible(true)
    self:SetFillAlpha(0.85)
    self:SetOffsets(-self.frameOffset, -self.frameOffset, self.frameOffset, self.frameOffset)
    UiTransform2dBus.Event.SetOffsets(self.Properties.FrameTextureMask, UiOffsets(-self.frameOffset, -self.frameOffset, self.frameOffset, self.frameOffset))
  elseif self.frameStyle == self.FRAME_STYLE_FULLSCREEN_RIGHT then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameBg, self.FRAME_STYLE_FULLSCREEN_BG_RIGHT_PATH)
    self:SetImageType(self.IMAGE_TYPE_STRETCHED)
    self:SetTextureVisible(false)
    self:SetFillAlpha(0.9)
    self:SetOffsets(0, 0, 0, 0)
  elseif self.frameStyle == self.FRAME_STYLE_FULLSCREEN_LEFT then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameBg, self.FRAME_STYLE_FULLSCREEN_BG_RIGHT_PATH)
    self:SetImageType(self.IMAGE_TYPE_STRETCHED)
    self:SetTextureVisible(false)
    self:SetFillAlpha(0.9)
    self.ScriptedEntityTweener:Set(self.Properties.FrameBg, {scaleX = -1})
    self:SetOffsets(0, 0, 0, 0)
  elseif self.frameStyle == self.FRAME_STYLE_SIDE_PANEL_RIGHT then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameBg, self.FRAME_STYLE_SIDE_PANEL_BG_RIGHT_PATH)
    self:SetImageType(self.IMAGE_TYPE_STRETCHED)
    self:SetTextureVisible(false)
    self:SetFillAlpha(1)
    self:SetOffsets(-54, 0, 0, 0)
  elseif self.frameStyle == self.FRAME_STYLE_SIDE_PANEL_LEFT then
    UiImageBus.Event.SetSpritePathname(self.Properties.FrameBg, self.FRAME_STYLE_SIDE_PANEL_BG_RIGHT_PATH)
    self:SetImageType(self.IMAGE_TYPE_STRETCHED)
    self:SetTextureVisible(false)
    self:SetFillAlpha(1)
    self.ScriptedEntityTweener:Set(self.Properties.FrameBg, {scaleX = -1})
    self:SetOffsets(0, 0, 54, 0)
  end
end
function FrameMultiBg:GetFrameStyle()
  return self.frameStyle
end
function FrameMultiBg:SetImageType(value)
  local isValid = value == self.IMAGE_TYPE_TILED or value == self.IMAGE_TYPE_FIXED or value == self.IMAGE_TYPE_SLICED or value == self.IMAGE_TYPE_STRETCHED
  if isValid then
    UiImageBus.Event.SetImageType(self.Properties.FrameBg, value)
  end
end
function FrameMultiBg:SetTextureVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.FrameTexture, isVisible)
end
function FrameMultiBg:SetFillAlpha(alpha, textureAlpha)
  self.ScriptedEntityTweener:Set(self.Properties.FrameBg, {opacity = alpha})
  self.ScriptedEntityTweener:Set(self.Properties.FrameTexture, {
    opacity = textureAlpha or alpha
  })
end
function FrameMultiBg:SetFrameTextureAlpha(alpha)
  self.ScriptedEntityTweener:Set(self.Properties.FrameTexture, {opacity = alpha})
end
function FrameMultiBg:SetOffsets(left, top, right, bottom)
  UiTransform2dBus.Event.SetOffsets(self.Properties.FrameBg, UiOffsets(left, top, right, bottom))
end
function FrameMultiBg:OnShutdown()
end
return FrameMultiBg
