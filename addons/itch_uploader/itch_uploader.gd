@tool
extends EditorPlugin
class_name ItchUploader

const TOOL_MENU_ITEM_NAME := "Export and Upload to Itch..."
const SETTINGS_TAB_NAME := "itch_uploader"

const EXPORT_SETTINGS_MODAL_RES := preload("res://addons/itch_uploader/ui/export_settings_modal/export_settings_modal.tscn")
var _export_settings_modal: ExportSettingsModal = null

const EXPORT_PROCESS_MODAL_RES := preload("res://addons/itch_uploader/ui/export_process_modal/export_process_modal.tscn")
var _export_process_modal: ExportProcessModal = null

var _export_preset_reader := ExportPresetReader.new()
var _itch_page_url_storage := ItchPageUrlStorage.new()

func _enter_tree():
	add_tool_menu_item(TOOL_MENU_ITEM_NAME, _open_export_settings_modal)
	_itch_page_url_storage.register_project_settings()

func _exit_tree():
	remove_tool_menu_item(TOOL_MENU_ITEM_NAME)
	_itch_page_url_storage.unregister_project_settings()

static func get_setting(field: String) -> String:
	return "{0}/{1}".format([SETTINGS_TAB_NAME, field])

func _open_export_settings_modal():
	_export_settings_modal = EXPORT_SETTINGS_MODAL_RES.instantiate()
	_export_settings_modal.theme = EditorInterface.get_editor_theme()
	_export_settings_modal.export_presets = _export_preset_reader.read_export_presets()
	_export_settings_modal.connect("export_accepted", self._start_export)
	EditorInterface.popup_dialog_centered(_export_settings_modal)

func _start_export(selected_export_presets: Array[ExportPreset], butler_path: String):
	_export_process_modal = EXPORT_PROCESS_MODAL_RES.instantiate()
	_export_process_modal.theme = EditorInterface.get_editor_theme()
	_export_process_modal.itch_page_url_storage = _itch_page_url_storage
	_export_process_modal.export_presets = selected_export_presets
	_export_process_modal.butler_path = butler_path
	EditorInterface.popup_dialog_centered(_export_process_modal)
