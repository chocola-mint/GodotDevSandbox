extends EditorInspectorPlugin

func _can_handle(object : Object):
	var script := object.get_script() as GDScript
	return script and script.is_tool()

func _parse_category(object: Object, category: String) -> void:
	var script := object.get_script() as GDScript
	if script.get_global_name() == category or script.resource_path.get_file() == category:
		for method_info : Dictionary in object.get_method_list():
			var method_name : String = method_info["name"]
			var annotations : Array = script.get_member_annotations(method_name)
			var tool_buttons : Array[ToolButton]
			for annotation : GDScriptAnnotation in annotations:
				var tool_button := annotation as ToolButton
				if tool_button:
					tool_buttons.push_back(tool_button)
			for tool_button in tool_buttons:
				add_custom_control(ToolButtonEditor.new(method_name, tool_button, object, 5))
				
class ToolButtonEditor extends MarginContainer:
	func _init(method_name : String, annotation : ToolButton, target : Object, margin_value : float) -> void:
		var button := Button.new()
		button.text = annotation.get_button_name()
		add_child(button)
		add_theme_constant_override("margin_top", margin_value)
		add_theme_constant_override("margin_left", margin_value)
		add_theme_constant_override("margin_bottom", margin_value)
		add_theme_constant_override("margin_right", margin_value)
		button.pressed.connect(Callable(target, method_name).bindv(annotation.get_args()))
