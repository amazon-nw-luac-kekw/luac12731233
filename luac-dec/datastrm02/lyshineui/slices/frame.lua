local Frame = {
  Properties = {
    FrameBg = {
      default = EntityId()
    },
    FrameTexture = {
      default = EntityId()
    },
    DrawnLineTop = {
      default = EntityId()
    },
    DrawnLineBottom = {
      default = EntityId()
    },
    DrawnLineLeft = {
      default = EntityId()
    },
    DrawnLineRight = {
      default = EntityId()
    },
    TopLineProperties = {
      Overshoot = {
        default = 0,
        description = "Sets how far the line will overshoot past it's width"
      },
      Offset = {
        default = 0,
        description = "Offsets the lines starting position. Supports +/- numbers"
      }
    },
    LeftLineProperties = {
      Overshoot = {
        default = 0,
        description = "Sets how far the line will overshoot past it's width"
      },
      Offset = {
        default = 0,
        description = "Offsets the lines starting position. Supports +/- numbers"
      }
    },
    BottomLineProperties = {
      Overshoot = {
        default = 0,
        description = "Sets how far the line will overshoot past it's width"
      },
      Offset = {
        default = 0,
        description = "Offsets the lines starting position. Supports +/- numbers"
      }
    },
    RightLineProperties = {
      Overshoot = {
        default = 0,
        description = "Sets how far the line will overshoot past it's width"
      },
      Offset = {
        default = 0,
        description = "Offsets the lines starting position. Supports +/- numbers"
      }
    }
  },
  mWidth = 0,
  mHeight = 0,
  mTopLineOffset = 0,
  mLeftLineOffset = 0,
  mBottomLineOffset = 0,
  mRightLineOffset = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Frame)
function Frame:OnInit()
  BaseElement.OnInit(self)
  if not self.DrawnLineTop or type(self.DrawnLineTop) ~= "table" then
    return
  end
  self.DrawnLineTop:OnInit()
  self.DrawnLineBottom:OnInit()
  self.DrawnLineLeft:OnInit()
  self.DrawnLineRight:OnInit()
  self.mTopLineOffset = self.TopLineProperties.Offset
  self.mLeftLineOffset = self.LeftLineProperties.Offset
  self.mBottomLineOffset = self.BottomLineProperties.Offset
  self.mRightLineOffset = self.RightLineProperties.Offset
  self.DrawnLineTop:SetOvershoot(self.TopLineProperties.Overshoot)
  self.DrawnLineBottom:SetOvershoot(self.BottomLineProperties.Overshoot)
  self.DrawnLineLeft:SetOvershoot(self.LeftLineProperties.Overshoot)
  self.DrawnLineRight:SetOvershoot(self.RightLineProperties.Overshoot)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.mWidth, self.mHeight)
end
function Frame:SetWidth(width)
  self:SetSize(width, self.mHeight)
end
function Frame:GetWidth()
  return self.mWidth
end
function Frame:SetHeight(height)
  self:SetSize(self.mWidth, height)
end
function Frame:GetHeight()
  return self.mHeight
end
function Frame:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
  self:SetLineOffset(self.mTopLineOffset, self.mLeftLineOffset, self.mBottomLineOffset, self.mRightLineOffset)
  self.DrawnLineTop:SetLength(self.mWidth)
  self.DrawnLineBottom:SetLength(self.mWidth)
  self.DrawnLineLeft:SetLength(self.mHeight)
  self.DrawnLineRight:SetLength(self.mHeight)
end
function Frame:SetLineVisible(isVisible, duration, params)
  local defaultDelay = 0
  local animDelay = defaultDelay
  if params ~= nil then
    animDelay = params.delay ~= nil and params.delay or defaultDelay
  end
  self.DrawnLineTop:SetVisible(isVisible, duration, {
    delay = animDelay + 0
  })
  self.DrawnLineBottom:SetVisible(isVisible, duration, {
    delay = animDelay + 0.1
  })
  self.DrawnLineLeft:SetVisible(isVisible, duration, {
    delay = animDelay + 0.05
  })
  self.DrawnLineRight:SetVisible(isVisible, duration, {
    delay = animDelay + 0.15
  })
end
function Frame:ResetLines()
  self.DrawnLineTop:Reset()
  self.DrawnLineBottom:Reset()
  self.DrawnLineLeft:Reset()
  self.DrawnLineRight:Reset()
end
function Frame:SetLineColor(color, duration, params)
  self.DrawnLineTop:SetColor(color, duration, params)
  self.DrawnLineBottom:SetColor(color, duration, params)
  self.DrawnLineLeft:SetColor(color, duration, params)
  self.DrawnLineRight:SetColor(color, duration, params)
end
function Frame:SetLineOffset(topOffset, leftOffset, bottmOffset, rightOffset)
  self.mTopLineOffset = topOffset
  self.mLeftLineOffset = leftOffset
  self.mBottomLineOffset = bottmOffset
  self.mRightLineOffset = rightOffset
  UiTransformBus.Event.SetLocalPosition(self.DrawnLineTop.entityId, Vector2(self.mTopLineOffset, 0))
  UiTransformBus.Event.SetLocalPosition(self.DrawnLineBottom.entityId, Vector2(self.mBottomLineOffset, self.mHeight))
  UiTransformBus.Event.SetLocalPosition(self.DrawnLineLeft.entityId, Vector2(0, self.mLeftLineOffset))
  UiTransformBus.Event.SetLocalPosition(self.DrawnLineRight.entityId, Vector2(self.mWidth, self.mRightLineOffset))
end
function Frame:SetLineAlpha(alpha)
  self.ScriptedEntityTweener:Set(self.DrawnLineTop.entityId, {opacity = alpha})
  self.ScriptedEntityTweener:Set(self.DrawnLineBottom.entityId, {opacity = alpha})
  self.ScriptedEntityTweener:Set(self.DrawnLineLeft.entityId, {opacity = alpha})
  self.ScriptedEntityTweener:Set(self.DrawnLineRight.entityId, {opacity = alpha})
end
function Frame:SetFillColor(color, duration, params)
  local defaultDuration = 0.5
  local defaultDelay = 0
  local defaultEase = "QuadOut"
  local animDuration = duration ~= nil and duration or defaultDuration
  local animDelay = defaultDelay
  local animEase = defaultEase
  if params ~= nil then
    animDelay = params.delay ~= nil and params.delay or defaultDelay
    animEase = params.ease ~= nil and params.ease or defaultEase
  end
  if duration ~= nil then
    self.ScriptedEntityTweener:Play(self.FrameBg, animDuration, {
      imgColor = color,
      ease = animEase,
      delay = animDelay
    })
  else
    UiImageBus.Event.SetColor(self.FrameBg, color)
  end
end
function Frame:SetFillAlpha(alpha)
  self.ScriptedEntityTweener:Set(self.FrameBg, {opacity = alpha})
end
function Frame:SetFrameTextureVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.FrameTexture, isVisible)
end
function Frame:OnShutdown()
end
return Frame
