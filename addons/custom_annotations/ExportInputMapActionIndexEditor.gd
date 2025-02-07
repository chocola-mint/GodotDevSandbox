extends EditorInspectorPlugin

func _can_handle(object : Object):
	var script := object.get_script()
	return script != null and script is GDScript

func _parse_property(object : Object, type : Variant.Type, name : String, hint_type : PropertyHint, hint_string : String, usage_flags : PropertyUsageFlags, wide : bool):
	if type == TYPE_INT:
		var script := object.get_script() as GDScript
		if script:
			var annotations := script.get_member_annotations(name)
			for annotation in annotations:
				if annotation is ExportInputMapActionIndex:
					var value = object.get(name)
					add_property_editor(name, InputMapActionIndexEditor.new(value if typeof(value) != TYPE_NIL else -1))
					return true
		return false
	else:
		return false

class InputMapActionIndexEditor extends EditorProperty:
	var options : OptionButton
	var updating : bool = false
	func _init(initial_id : int) -> void:
		options = OptionButton.new()
		options.add_item("[INVALID]", -1)
		options.add_separator()
		var actions := InputMap.get_actions()
		for i in range(actions.size()):
			# We have to filter out editor input actions
			# because the code is executed in editor.
			if not "editor".is_subsequence_of(actions[i]):
				options.add_item(actions[i], i)
		add_child(options)
		add_focusable(options)
		_select_id(initial_id)
		options.item_selected.connect(_item_selected)
		
	func _item_selected(index : int) -> void:
		emit_changed(get_edited_property(), index)
	
	func _update_property() -> void:
		var new_index = get_edited_object()[get_edited_property()]
		_select_id(-1 if typeof(new_index) == TYPE_NIL else new_index)
	
	func _select_id(id : int) -> void:
		for i in range(2, options.item_count):
			if options.get_item_id(i) == id:
				options.select(i - 2)
				return
		options.select(0) # [INVALID]
