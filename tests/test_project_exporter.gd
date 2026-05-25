extends Object

const MOCK_DIR := "tests/mock"

func test() -> Error:
	var dir_access := DirAccess.open(".")

	if dir_access.dir_exists(".export"):
		push_error("Directory already exists: .export")
		return FAILED

	var mock_butler_log := MOCK_DIR.path_join("butler.log")
	if dir_access.file_exists(mock_butler_log):
		print("Removing mock Butler log file")
		var remove_error := dir_access.remove(MOCK_DIR.path_join("butler.log"))
		if remove_error != OK:
			push_error("Could not remove mock Butler log: " + error_string(remove_error))
			return FAILED

	var itch_page_url_storage := ItchPageUrlStorage.new()
	var godot_runner := GodotRunner.new()
	var butler_runner := ButlerRunner.new()
	var project_exporter := ProjectExporter.new(itch_page_url_storage, butler_runner, godot_runner)

	var mock_butler_exe: String
	if OS.get_name() == 'Windows':
		mock_butler_exe = dir_access.get_current_dir().path_join(MOCK_DIR).path_join("butler.bat")
	else:
		mock_butler_exe = dir_access.get_current_dir().path_join(MOCK_DIR).path_join("butler")

	print("Setting Butler executable to " + mock_butler_exe)
	butler_runner.save_butler_executable(mock_butler_exe)

	var export_preset := ExportPreset.new(
		"Linux",
		"Linux",
		".export/linux/dummy.x86_64",
		"linux",
	)

	var export_log: Array[String] = []
	var export_result := project_exporter.export_preset(export_preset, export_log)

	for line in export_log:
		print(line)

	if export_result != OK:
		push_error("Failed to run project exporter")
		return FAILED

	print("Validating mock Butler log")

	var mock_butler_log_file := FileAccess.open(mock_butler_log, FileAccess.READ)
	var mock_butler_log_contents := mock_butler_log_file.get_as_text()

	print("Mock Butler log:\n" + mock_butler_log_contents)

	if not mock_butler_log_contents.contains("SUCCESS: Push called, source=.export/linux, target=redteapot/test:linux"):
		push_error("Mock Butler log does not contain the SUCCESS line")
		return FAILED

	return OK
