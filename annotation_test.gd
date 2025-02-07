@tool
@@ClassTag("Enemy")
extends Node2D

## Unit vector with a convenient inspector.
@@ExportDirection2D
var direction : Vector2 = Vector2.RIGHT

## Index to an input action in InputMap.get_actions().
@@ExportInputMapActionIndex
var input_action_index : int = -1

@@ExportInputMapActionIndex
var another_input_action_index : int = -1

@@ExportDirection2D
var other_direction : Vector2 = Vector2.RIGHT

@@ToolButton("Say Hello", '"world", 0')
@@ToolButton("Say Hello 2", '"world 2"')
func hello(to_who : String, _x : int = 2) -> void:
	print("hello " + to_who)

@@ToolButton("Dump Annotations")
func dump_annotations() -> void:
	var script := get_script() as GDScript
	print("-- Class --")
	for annotation : GDScriptAnnotation in script.get_class_annotations():
		print(annotation.get_name())
	print("-- Members --")
	for member in script.get_members_with_annotations():
		print(member + ":")
		for annotation : GDScriptAnnotation in script.get_member_annotations(member):
			print("---- " + annotation.get_name())
