extends GDScriptVariableAnnotation
## Annotation that lets you edit a vector while ensuring
## that it is always a unit vector.
## 
## You can edit the value by moving the arrow on the left
## with your mouse, and you can also set values by specifying
## The angle in degrees.
class_name ExportDirection2D

func _init() -> void:
	pass

func _is_export_annotation() -> bool:
	return true

func _analyze(name: StringName, type_name: StringName, type: Variant.Type, is_static: bool) -> void:
	if type != TYPE_VECTOR2:
		error_message = "Annotation \"%s\" can only be used on Vector2s." % get_name()
		return
