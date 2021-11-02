BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local MapTile = {
  Properties = {},
  tile = nil,
  filename = "",
  isLoaded = false,
  FILE_EXISTS = 1,
  FILE_DOES_NOT_EXIST = 0
}
BaseElement:CreateNewElement(MapTile)
function MapTile:OnInit()
end
function MapTile:SetTile(tile, isVisible, filenameExistenceMap)
  self.tile = tile
  local filename = string.format("%s/map_L%d_Y%03d_X%03d.png", tile.worldMapData.folder, tile.contentLevel, tile.ty, tile.tx)
  if filename ~= self.filename then
    self:UnloadTexture()
    self.filename = filename
    self.isLoaded = false
    self.existenceStatus = nil
  end
  if isVisible then
    self:ReloadTexture(filenameExistenceMap)
  end
end
function MapTile:ReloadTexture(filenameExistenceMap)
  if self.filename == "" then
    return
  end
  self.existenceStatus = self.existenceStatus or filenameExistenceMap[self.filename]
  if not self.existenceStatus then
    self.isLoaded = UiImageBus.Event.SetSpritePathnameIfExists(self.entityId, self.filename)
    if self.isLoaded then
      self.existenceStatus = self.FILE_EXISTS
    else
      self.existenceStatus = self.FILE_DOES_NOT_EXIST
    end
    filenameExistenceMap[self.filename] = self.existenceStatus
  elseif self.existenceStatus == self.FILE_EXISTS then
    if not self.isLoaded then
      UiImageBus.Event.SetSpritePathname(self.entityId, self.filename)
      self.isLoaded = true
    end
  elseif self.existenceStatus == self.FILE_DOES_NOT_EXIST then
    self.isLoaded = false
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isLoaded)
end
function MapTile:UnloadTexture()
  if self.filename ~= "" and self.isLoaded then
    UiImageBus.Event.UnloadTexture(self.entityId)
    self.isLoaded = false
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
return MapTile
