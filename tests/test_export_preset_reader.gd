extends Object

func test() -> Error:
	var reader := ExportPresetReader.new()

	var read_presets := reader.read_export_presets()

	print_debug("Read presets: " + str(read_presets))

	var expected_presets := [
		ExportPreset.new(
			"Web",
			"Web",
			".export/web/index.html",
			"web",
		),
		ExportPreset.new(
			"Windows Desktop",
			"Windows Desktop",
			".export/windows/dummy.exe",
			"windows",
		),
		ExportPreset.new(
			"Linux",
			"Linux",
			".export/linux/dummy.x86_64",
			"linux",
		),
		ExportPreset.new(
			"macOS",
			"macOS",
			".export/macos/dummy.app",
			"macos",
		),
	]

	print_debug("Expected presets: " + str(expected_presets))

	if read_presets.size() != expected_presets.size():
		push_error("Read and expected preset counts do not match")
		return FAILED

	for read_preset in read_presets:
		var found := false
		for expected_preset in expected_presets:
			if read_preset.equals(expected_preset):
				found = true
		if not found:
			push_error("Could not find export preset in expected list: " + str(read_preset))
			return FAILED

	return OK
