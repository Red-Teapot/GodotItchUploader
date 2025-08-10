@tool
extends Window
class_name ExportSettingsModal

signal export_accepted(selected_export_presets: Array[ExportPreset], butler_path: String)

var export_presets: Array[ExportPreset] = []

@onready var _butler_path_picker := %"ButlerPathPicker"
@onready var _butler_error_dialog := %"ButlerErrorDialog"
@onready var _export_preset_container := %"ExportPresetsContainer"
@onready var _no_presets_dialog := %"NoPresetsDialog"

var _export_preset_checkboxes: Dictionary[ExportPreset, CheckBox] = {}

const BUTLER_SETTINGS_FILE := "addons/itch_uploader/butler.cfg"
var _butler_settings := ConfigFile.new()
const DEFAULT_BUTLER_PATH := "butler"

func _ready():
	if is_part_of_edited_scene():
		return
	
	_butler_path_picker.path = _read_butler_executable()
	
	for preset in export_presets:
		var checkbox := CheckBox.new()
		checkbox.text = preset.name
		checkbox.button_pressed = true
		_export_preset_checkboxes[preset] = checkbox
		_export_preset_container.add_child(checkbox)

func _on_close_requested():
	queue_free()

func _on_upload_button_pressed():
	var butler_path: String = _butler_path_picker.path
	
	if not _is_butler_executable_valid(butler_path):
		_butler_error_dialog.show()
		return
	
	_save_butler_executable(butler_path)
	
	var selected_export_presets: Array[ExportPreset] = []
	for preset in export_presets:
		if preset not in _export_preset_checkboxes:
			continue
			
		var checkbox := _export_preset_checkboxes[preset]
		if not checkbox.button_pressed:
			continue
		
		selected_export_presets.append(preset)
	
	if selected_export_presets.is_empty():
		_no_presets_dialog.show()
		return
		
	hide()
	
	emit_signal(
		"export_accepted", 
		selected_export_presets, 
		butler_path if not butler_path.is_empty() else DEFAULT_BUTLER_PATH,
	)
	
	queue_free()

func _is_butler_executable_valid(path: String) -> bool:
	if path.is_empty():
		path = DEFAULT_BUTLER_PATH
		
	var output: Array[String] = []
	var result := OS.execute(path, ["--help"], output, true, false)
	
	if result < 0:
		return false
	
	if output.is_empty():
		return false
	
	var output_str := output[0]
	if not output_str.contains("Your happy little itch.io helper"):
		return false
	
	return true

func _read_butler_executable() -> String:
	_butler_settings.clear()
	var result := _butler_settings.load(BUTLER_SETTINGS_FILE)
	if result != OK:
		return ""
	
	return _butler_settings.get_value("butler", "path", "")

func _save_butler_executable(path: String):
	_butler_settings.clear()
	_butler_settings.set_value("butler", "path", path)
	_butler_settings.save(BUTLER_SETTINGS_FILE)
