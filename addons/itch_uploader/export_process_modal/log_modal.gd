@tool
extends Window

@export var log: Array[String] = []

@onready var _log_text := %"LogText"

func _ready():
	_log_text.clear()
	for entry in log:
		_log_text.add_text(entry)
		_log_text.newline()

func _on_close_requested():
	queue_free()
