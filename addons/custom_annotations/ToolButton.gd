extends GDScriptFunctionAnnotation

class_name ToolButton

var _args : Array
var _name : String

func get_button_name() -> String:
	return _name

func get_args() -> Array:
	return _args

func _get_allow_multiple() -> bool:
	return true
	
func _init(name : String, args : String = "") -> void:
	_name = name
	if not args.is_empty():
		for arg_str in args.split(","):
			var parsed_value = str_to_var(arg_str)
			if typeof(parsed_value) == TYPE_NIL:
				error_message = "Failed to parse args string: %s (Index: %d)" % [ arg_str, _args.size() ]
				return
			_args.push_back(parsed_value)

func _analyze(name: StringName, parameter_names: PackedStringArray, parameter_type_names: PackedStringArray, parameter_builtin_types: PackedInt32Array, return_type_name: StringName, return_builtin_type: Variant.Type, default_arguments: Array, is_static: bool, is_coroutine: bool) -> void:
	var args_str := str(_args)
	args_str = args_str.substr(1, len(args_str) - 2)
	var min_args_count := parameter_names.size() - default_arguments.size()
	if _args.size() < min_args_count:
		if min_args_count == parameter_names.size():
			error_message = "Expected %d arguments for function \"%s\","
		else:
			error_message = "Expected at least %d arguments for function \"%s\","
		error_message = (error_message + " but got %d arguments instead.") % [min_args_count, name, _args.size()]
		return
	elif _args.size() > parameter_names.size():
		error_message = "Expected %d arguments for function \"%s\", but got %d arguments instead." % [parameter_names.size(), name, _args.size()]
		return
	for i in range(_args.size()):
		var type : int = parameter_builtin_types[i]
		if type < TYPE_MAX and type != typeof(_args[i]):
			error_message = "Type mismatch on argument #%d. (Expected %d but got %d)" % [i + 1, type, typeof(_args[i])]
			return
