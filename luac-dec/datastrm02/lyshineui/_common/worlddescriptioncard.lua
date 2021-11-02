local WorldDescriptionCard = {
  Properties = {
    WorldNameEntity = {
      default = EntityId()
    },
    WorldDescriptionHolder = {
      default = EntityId()
    },
    WorldDescriptionEntity = {
      default = EntityId()
    },
    MotDHolder = {
      default = EntityId()
    },
    MotDEntity = {
      default = EntityId()
    },
    MotDBg = {
      default = EntityId()
    },
    MotDLearnMoreButton = {
      default = EntityId()
    },
    WorldImage = {
      default = EntityId()
    }
  },
  motdBgMaxScrollHeight = 180,
  motdScrollBoxHeight = 170,
  imagePathRoot = "lyshineui/images/landingscreen/serverimage/serverImageMedium",
  defaultImagePath = "lyshineui/images/landingscreen/serverimage/serverImageMedium1.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WorldDescriptionCard)
function WorldDescriptionCard:OnInit()
  BaseElement.OnInit(self)
  if not self.Properties.WorldNameEntity:IsValid() then
    Debug.Log("WorldInfoCard: Lua property WorldNameEntity is not set")
  end
end
function WorldDescriptionCard:SetWorldDescription(worldName, worldDescription, motd, worldData)
  UiTextBus.Event.SetText(self.Properties.WorldNameEntity, tostring(worldName))
  if self.Properties.WorldDescriptionEntity:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldDescriptionEntity, worldDescription, eUiTextSet_SetLocalized)
  end
  local isWorldDescriptionVisible = worldDescription ~= ""
  if isWorldDescriptionVisible then
    self.ScriptedEntityTweener:Play(self.Properties.WorldDescriptionHolder, 0.3, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MotDHolder, 0.3, {y = 0, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.WorldDescriptionHolder, 0.3, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MotDHolder, 0.3, {y = -70, ease = "QuadOut"})
  end
  if self.Properties.MotDEntity:IsValid() then
    local mergeMessage
    if 0 < worldData.mergeTime then
      local mergeTime = os.date("%c", worldData.mergeTime)
      mergeMessage = GetLocalizedReplacementText("@ui_mergewarning_long", {
        worldName = worldData.mergeDestinationName,
        time = mergeTime
      })
    end
    local motdText = motd
    if mergeMessage ~= nil then
      if motdText ~= "" then
        motdText = motdText .. [[


]] .. mergeMessage
      else
        motdText = mergeMessage
      end
    end
    local isMotdVisible = motdText ~= ""
    local tweenAlpha = isMotdVisible and 1 or 0
    self.ScriptedEntityTweener:Play(self.Properties.MotDHolder, 0.3, {opacity = tweenAlpha, ease = "QuadOut"})
    UiTextBus.Event.SetTextWithFlags(self.Properties.MotDEntity, motdText, eUiTextSet_SetLocalized)
    if isMotdVisible then
      LyShineManagerBus.Broadcast.SetServerMOTD(motdText)
    end
    local motdTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.MotDEntity)
    local motdTextPadding = 45
    local motdBgHeight = motdTextHeight + motdTextPadding
    if motdTextHeight >= self.motdScrollBoxHeight then
      motdBgHeight = self.motdBgMaxScrollHeight + motdTextPadding
    end
    local isLearnMoreButtonVisible = UiElementBus.Event.IsEnabled(self.Properties.MotDLearnMoreButton)
    if isLearnMoreButtonVisible then
      local buttonHeight = self.MotDLearnMoreButton:GetHeight()
      local buttonPadding = 10
      local buttonPosY = motdBgHeight - motdTextPadding + buttonPadding
      self.ScriptedEntityTweener:Set(self.Properties.MotDLearnMoreButton, {y = buttonPosY})
      motdBgHeight = motdBgHeight + buttonHeight + buttonPadding
    end
    self.ScriptedEntityTweener:Play(self.Properties.MotDBg, 0.3, {h = motdBgHeight, ease = "QuadOut"})
  end
  if worldData.imageId then
    local imagePath = self.imagePathRoot .. worldData.imageId .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.WorldImage, imagePath)
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.WorldImage, self.defaultImagePath)
  end
end
return WorldDescriptionCard
