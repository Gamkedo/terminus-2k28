extends Node

enum Level { TRACE, DEBUG, INFO, WARNING, ERROR }

var level_strings: Dictionary[Level, String] = {
	Level.TRACE : "TRACE",
	Level.DEBUG : "DEBUG",
	Level.INFO : "INFO",
	Level.WARNING : "WARNING",
	Level.ERROR : "ERROR"

}

const THRESHOLD = Level.TRACE

func _log(message: String, level: Level) -> void:
	if level < THRESHOLD: return

	var log_msg: String = "[%s]%s " % [ _get_time(), _get_level_str(level),] + message

	match level:
		Level.TRACE:
			print_rich("[color=gray]" + log_msg)
		Level.DEBUG:
			print_rich("[color=cyan]" + log_msg)
		Level.INFO:
			print_rich("[color=green]" + log_msg)
		Level.WARNING:
			push_warning(log_msg)
		Level.ERROR:
			push_error(log_msg)

func _get_time() -> String:
	return Time.get_datetime_string_from_system()

func _get_level_str(level: Level) -> String:
	var level_str: String = "["+level_strings[level]+"]"
	return level_str.rpad(8) + "|"

func trace(message: Variant) -> void:
	if OS.is_debug_build():
		_log("    " + str(message), Level.TRACE)

func debug(message: Variant) -> void:
	if OS.is_debug_build():
		_log("  " + str(message), Level.DEBUG)

func info(message: Variant) -> void:
	if OS.is_debug_build():
		_log(str(message), Level.INFO)

func warning(message: Variant) -> void:
	_log(str(message), Level.WARNING)

func error(message: Variant) -> void:
	_log(str(message), Level.ERROR)
