@tool
extends Window

var export_presets: Array[ExportPreset] = []

@onready var _butler_path_picker := %"ButlerPathPicker"
@onready var _butler_error_dialog := %"ButlerErrorDialog"
@onready var _export_preset_container := %"ExportPresetsContainer"

var _export_preset_checkboxes: Dictionary[ExportPreset, CheckBox] = {}

func _ready():
	for preset in export_presets:
		var checkbox := CheckBox.new()
		checkbox.text = preset.name
		checkbox.button_pressed = true
		_export_preset_checkboxes[preset] = checkbox
		_export_preset_container.add_child(checkbox)

func _on_close_requested():
	queue_free()

func _is_butler_executable_valid(path: String) -> bool:
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

func _on_upload_button_pressed():
	var butler_path: String = _butler_path_picker.path
	if butler_path.is_empty():
		# Maybe it's in PATH
		butler_path = "butler"
	
	if not _is_butler_executable_valid(butler_path):
		_butler_error_dialog.visible = true
		return
	
	queue_free()
