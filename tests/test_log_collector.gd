extends Object

func test() -> Error:
	var log_collector := LogCollector.new()
	
	var line_1 := "[92m[ DONE ][39m [1mfirst_scan_filesystem[22m"
	var line_2 := "[  96% ] [90m[1msavepack[22m | Storing File: res://.godot/uid_cache.bin[39m[0m"
	
	print_debug("Raw logs:\n" + line_1 + "\n" + line_2)
	
	log_collector.add_line(line_1)
	log_collector.add_line(line_2)

	var clean_logs := "[ DONE ] first_scan_filesystem"\
		+ "\n" + "[  96% ] savepack | Storing File: res://.godot/uid_cache.bin"
	
	print_debug("Clean lines (expected):\n" + clean_logs)
	
	var formatted_log := log_collector.get_log()
	
	print_debug("Clean lines (actual):\n" + formatted_log)
	
	if formatted_log != clean_logs:
		return FAILED
	
	return OK
