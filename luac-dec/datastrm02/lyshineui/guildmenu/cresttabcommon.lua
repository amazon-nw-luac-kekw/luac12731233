local CrestTabCommon = {}
function CrestTabCommon:ResizeImageList(imageListEntityId)
  local numChildren = UiElementBus.Event.GetNumChildElements(imageListEntityId)
  local contentOffsets = UiTransform2dBus.Event.GetOffsets(imageListEntityId)
  local width = UiTransform2dBus.Event.GetLocalWidth(imageListEntityId)
  local padding = UiLayoutGridBus.Event.GetPadding(imageListEntityId)
  local spacing = UiLayoutGridBus.Event.GetSpacing(imageListEntityId)
  local cellSize = UiLayoutGridBus.Event.GetCellSize(imageListEntityId)
  local numPerRow = (width - padding.left - padding.right + spacing.x) / (cellSize.x + spacing.x)
  local numRows = math.ceil(numChildren / math.floor(numPerRow))
  local height = padding.top + cellSize.y * numRows + spacing.y * (numRows - 1) + padding.bottom
  contentOffsets.bottom = contentOffsets.top + height
  UiTransform2dBus.Event.SetOffsets(imageListEntityId, contentOffsets)
end
return CrestTabCommon
