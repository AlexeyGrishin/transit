# This formatting function wraps the data with specified start and end tag.
#
# By default the text is wrapped into the 'font' tag with monospace font definition.
module.exports = (before = "<font face='courier'>", after = "</font>") ->
  (data) -> before + data + after


