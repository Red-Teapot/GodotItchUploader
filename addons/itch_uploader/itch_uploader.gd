@tool
extends EditorPlugin

const TOOL_MENU_ITEM_NAME := "Export & Upload to Itch"
const SETTINGS_TAB_NAME := "itch_uploader"
const ITCH_PAGE_URL_FIELD := "itch_page_url"
const BUTLER_EXE_FIELD := "butler_executable"

var ITCH_PAGE_URL_REGEX := RegEx.new()
const ITCH_CHANNELS := {
	"Web": "web",
	"Windows Desktop": "windows",
	"macOS": "macos",
	"Linux": "linux",
}

func _enter_tree():
	ITCH_PAGE_URL_REGEX.compile("^https://(?<user>[a-zA-Z0-9_-]+)\\.itch\\.io/(?<game>[a-zA-Z0-9_-]+)$")
	
	add_tool_menu_item(TOOL_MENU_ITEM_NAME, _export_and_upload)
	
	ProjectSettings.set(_get_setting(ITCH_PAGE_URL_FIELD), "")
	ProjectSettings.set_as_basic(_get_setting(ITCH_PAGE_URL_FIELD), true)
	ProjectSettings.set_initial_value(_get_setting(ITCH_PAGE_URL_FIELD), "")
	ProjectSettings.add_property_info({
		"name": _get_setting(ITCH_PAGE_URL_FIELD),
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": "https://user.itch.io/game",
	})
	
	ProjectSettings.set(_get_setting(BUTLER_EXE_FIELD), "")
	ProjectSettings.set_as_basic(_get_setting(BUTLER_EXE_FIELD), true)
	ProjectSettings.set_initial_value(_get_setting(BUTLER_EXE_FIELD), "")
	ProjectSettings.add_property_info({
		"name": _get_setting(BUTLER_EXE_FIELD),
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_FILE,
		"hint_string": null,
	})

func _exit_tree():
	remove_tool_menu_item(TOOL_MENU_ITEM_NAME)
	ProjectSettings.set("{0}/{1}".format([SETTINGS_TAB_NAME, ITCH_PAGE_URL_FIELD]), null)
	ProjectSettings.set("{0}/{1}".format([SETTINGS_TAB_NAME, BUTLER_EXE_FIELD]), null)

func _get_setting(field: String) -> String:
	return "{0}/{1}".format([SETTINGS_TAB_NAME, field])

func _export_and_upload():
	var export_presets := ConfigFile.new()
	var error := export_presets.load("res://export_presets.cfg")
	if error:
		printerr(error)
		return
		
	var itch_page_url_match := ITCH_PAGE_URL_REGEX.search(ProjectSettings.get_setting(_get_setting(ITCH_PAGE_URL_FIELD), ""))
	if not itch_page_url_match:
		printerr("Invalid Itch page URL")
		return
	var itch_user := itch_page_url_match.get_string("user")
	var itch_game := itch_page_url_match.get_string("game")
	
	for section in export_presets.get_sections():
		if not section.begins_with("preset."):
			continue
		if section.ends_with(".options"):
			continue
		
		var is_runnable = export_presets.get_value(section, "runnable", false)
		if not is_runnable:
			continue
		
		var platform = export_presets.get_value(section, "platform")
		if not platform or platform not in ITCH_CHANNELS:
			continue
		
		var preset_name := export_presets.get_value(section, "name")
		var itch_channel: String = ITCH_CHANNELS[platform]
		
		print("Exporting channel ", itch_channel)
		
		var godot_pid := OS.create_instance([
			"--headless",
			"--export-release",
			preset_name,
		])
		if godot_pid < 0:
			printerr("Could not run Godot")
			continue
		while OS.is_process_running(godot_pid):
			OS.delay_msec(1000)
		var godot_exit_code := OS.get_process_exit_code(godot_pid)
		if godot_exit_code != 0:
			printerr("Running Godot export failed")
			continue
		
		print("Pushing channel ", itch_channel)
		
		var butler_pid := OS.create_process(
			"butler",
			[
				"push",
				".export/" + itch_channel,
				"{0}/{1}:{2}".format([itch_user, itch_game, itch_channel]),
			],
		)
		if butler_pid < 0:
			printerr("Could not run Butler")
			continue
		while OS.is_process_running(butler_pid):
			OS.delay_msec(1000)
		var butler_exit_code := OS.get_process_exit_code(butler_pid)
		if butler_exit_code != 0:
			printerr("Running Butler push failed")
			continue
