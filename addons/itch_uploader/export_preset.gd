@tool
extends RefCounted
class_name ExportPreset

var name: String
var platform: String
var path: String
var channel: String

func _init(name: String, platform: String, path: String, channel: String):
	self.name = name
	self.platform = platform
	self.path = path
	self.channel = channel
