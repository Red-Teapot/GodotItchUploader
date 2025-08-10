@tool
extends Window
class_name ExportProcessModal

var itch_page_url: String
var export_presets: Array[ExportPreset]
var butler_path: String

const PROCESS_ENTRY_RES := preload("res://addons/itch_uploader/export_process_modal/export_process_entry.tscn")
const LOG_MODAL_RES := preload("res://addons/itch_uploader/export_process_modal/log_modal.tscn")

@onready var _process_entry_container := %"ProcessEntryContainer"
@onready var _ok_button := %"OkButton"

var _itch_page_url_regex := RegEx.new()
var _itch_user: String
var _itch_project: String

var _process_entries: Dictionary[ExportPreset, ExportProcessEntry] = {}
var _logs: Dictionary[ExportPreset, Array] = {}
var _thread := Thread.new()

func _enter_tree():
	if is_part_of_edited_scene():
		return
		
	_itch_page_url_regex.compile("^https://(?<user>[a-zA-Z0-9_-]+)\\.itch\\.io/(?<project>[a-zA-Z0-9_-]+)$")
	var page_match := _itch_page_url_regex.search(itch_page_url)
	if not page_match:
		hide()
		queue_free()
		
		var error_dialog := AcceptDialog.new()
		error_dialog.title = "Incorrect Itch Page URL"
		error_dialog.dialog_text = "Incorrect Itch page URL: '{0}'. It should look like this: '{1}'.".format([
			itch_page_url,
			ItchUploader.ITCH_PAGE_URL_EXAMPLE,
		])
		EditorInterface.popup_dialog_centered(error_dialog)
		return
	
	_itch_user = page_match.get_string("user")
	_itch_project = page_match.get_string("project")

func _ready():
	_ok_button.disabled = true
	
	for preset in export_presets:
		var process_entry := PROCESS_ENTRY_RES.instantiate()
		process_entry.label = preset.name
		process_entry.connect("log_requested", self._on_log_requested.bind(preset))
		_process_entries[preset] = process_entry
		_process_entry_container.add_child(process_entry)
		process_entry.state = ExportProcessEntry.State.WAITING
	
	var result := _thread.start(self._run_export)
	if result != OK:
		printerr("Could not start the thread")

func _on_log_requested(preset: ExportPreset):
	if preset not in _logs:
		return
	
	print("Log requested for " + preset.name)
	
	var modal := LOG_MODAL_RES.instantiate()
	modal.log = _logs[preset]
	add_child(modal)
	modal.show()

func _on_close_requested():
	if _thread.is_alive():
		return
	
	_thread.wait_to_finish()
	queue_free()

func _run_export():
	for preset in export_presets:
		_process_entries[preset].call_deferred("set_state", ExportProcessEntry.State.IN_PROGRESS)
		
		var result := _export_preset(preset)
		
		if result == OK:
			_process_entries[preset].call_deferred("set_state", ExportProcessEntry.State.SUCCESS)
		else:
			_process_entries[preset].call_deferred("set_state", ExportProcessEntry.State.ERROR)
	
	_ok_button.call_deferred("set_disabled", false)

func _export_preset(preset: ExportPreset) -> Error:
	var output: Array[String] = []
	
	var godot_path := OS.get_executable_path()
	var godot_args := [
		"--headless",
		"--export-release",
		preset.name,
	]
	output.append("Godot path: " + godot_path)
	output.append("Godot args: " + str(godot_args))
	var godot_result := OS.execute(
		godot_path,
		godot_args,
		output,
		true,
		false,
	)
	if godot_result < 0:
		_logs[preset] = output
		return ERR_CANT_CREATE
	elif godot_result > 0:
		_logs[preset] = output
		return FAILED
	
	var butler_args := [
		"push",
		preset.path.get_base_dir(),
		"{0}/{1}:{2}".format([
			_itch_user,
			_itch_project,
			preset.channel,
		]),
	]
	output.append("Butler path: " + butler_path)
	output.append("Butler args: " + str(butler_args))
	var butler_result := OS.execute(
		butler_path,
		butler_args,
		output,
		true,
		false,
	)
	if butler_result < 0:
		_logs[preset] = output
		return ERR_CANT_CREATE
	elif butler_result > 0:
		_logs[preset] = output
		return FAILED
	
	return OK
