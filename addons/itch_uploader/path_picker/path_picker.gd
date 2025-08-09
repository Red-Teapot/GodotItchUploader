@tool
extends Control
class_name PathPicker

signal path_changed(path)

@export var path: String : set = _set_path

@onready var _path_edit := $"PathEdit"
@onready var _file_dialog := $"FileDialog"

func _set_path(value):
	if path == value:
		return
		
	path = value
	emit_signal("path_changed", value)

func _on_path_edit_text_changed(new_text):
	path = new_text

func _on_choose_button_pressed():
	if _file_dialog.visible:
		return
	
	_file_dialog.visible = true

func _on_file_dialog_file_selected(path):
	_file_dialog.visible = false
	self.path = path
	_path_edit.text = path
