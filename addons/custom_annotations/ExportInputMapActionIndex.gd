extends GDScriptVariableAnnotation
## Annotation that lets you select an InputMap action
## with a dropdown menu and store it as an index to the
## InputMap.get_actions() array.
## 
## Values outside of the array range are shown as [INVALID]
## in the inspector.
class_name ExportInputMapActionIndex

func _is_export_annotation() -> bool:
	return true

func _init() -> void:
	pass
	
func _analyze(name : StringName, type_name : StringName, builtin_type : int, is_static : bool) -> void:
	if builtin_type != TYPE_INT:
		error_message = "Annotation \"%s\" can only be used on integers. (int)" % get_name()
		return
