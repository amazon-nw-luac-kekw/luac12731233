local DyePickerCommon = {
  staticRecentColorData = {}
}
function DyePickerCommon:Reset()
  ClearTable(self.staticRecentColorData)
end
return DyePickerCommon
