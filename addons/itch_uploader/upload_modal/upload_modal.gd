@tool
extends Window

@onready var _butler_error_dialog := $"ButlerErrorDialog"

func _on_close_requested():
	queue_free()

func _on_butler_path_picker_path_changed(path):
	if not _is_butler_executable_valid(path):
		_butler_error_dialog.visible = true

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
