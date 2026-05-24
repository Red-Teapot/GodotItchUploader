extends SceneTree

const TESTS := [
	"res://tests/test_export_preset_reader.gd",
]

func _init() -> void:
	var godot_path := OS.get_executable_path()

	print("Godot path: " + godot_path)

	var swap_result := _swap_export_presets()
	if swap_result != OK:
		print("Could not swap export presets file: " + error_string(swap_result))
		quit(1)
		return

	var has_failures := false

	for test in TESTS:
		print("Running test " + test)

		var out_log: Array[String] = []
		var godot_args := [
			"--headless",
			"--script",
			test,
		]
		var godot_result := OS.execute(
			godot_path,
			godot_args,
			out_log,
			true,
			false,
		)

		if godot_result == OK:
			print("Passed test " + test)
		else:
			has_failures = true
			var message = "FAILED test " + test
			message += "\nTEST LOG:"
			for line in out_log:
				message += "\n" + line
			push_error(message)

	if has_failures:
		quit(1)
	else:
		quit(0)

func _swap_export_presets() -> Error:
	var dir_access := DirAccess.open(".")
	var engine_version := Engine.get_version_info()

	var source_path := "tests/export_presets/{major}.{minor}.{patch}/export_presets.cfg".format(engine_version)
	var dest_path := "export_presets.cfg"

	if not dir_access.file_exists(source_path):
		push_warning("Export presets file " + source_path + " does not exist, using the default one")
		return OK

	var remove_result := dir_access.remove(dest_path)
	if remove_result != OK:
		push_error("Could not remove" + dest_path)
		return remove_result
	var copy_result := dir_access.copy(source_path, dest_path)
	if copy_result != OK:
		push_error("Could not copy " + source_path + " to " + dest_path)
		return copy_result

	return OK
