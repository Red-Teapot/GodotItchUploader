@tool
extends Window

var log: LogCollector = null

@onready var _log_text := %"LogText"

func _ready():
	if log:
		_log_text.text = log.get_log()
	else:
		push_warning("Log modal opened with no log")
		_log_text.text = ""

func _on_close_requested():
	queue_free()
