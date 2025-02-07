extends EditorInspectorPlugin

func _can_handle(object : Object):
	var script := object.get_script()
	return script != null and script is GDScript
	
func _parse_property(object : Object, type : Variant.Type, name : String, hint_type : PropertyHint, hint_string : String, usage_flags : PropertyUsageFlags, wide : bool):
	if type == TYPE_VECTOR2:
		var script := object.get_script() as GDScript
		if script:
			var annotations := script.get_member_annotations(name)
			for annotation in annotations:
				if annotation is ExportDirection2D:
					var editor_property := Direction2DEditorProperty.new()
					add_property_editor(name, editor_property)
					
					var editor_canvas := Direction2DEditorCanvas.new(editor_property, object.get(name) if typeof(object.get(name)) != TYPE_NIL else Vector2.RIGHT)
					editor_property.editor_canvas = editor_canvas
					var aspect_ratio_container := AspectRatioContainer.new()
					aspect_ratio_container.add_child(editor_canvas)
					var hbox_container := HBoxContainer.new()
					hbox_container.add_child(aspect_ratio_container)
					hbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
					var editor_ui := Direction2DEditorUI.new(editor_property, editor_canvas)
					hbox_container.add_child(editor_ui)
					var margin_container := MarginContainer.new()
					const margin_value = 5
					margin_container.add_theme_constant_override("margin_top", margin_value)
					margin_container.add_theme_constant_override("margin_left", margin_value)
					margin_container.add_theme_constant_override("margin_bottom", margin_value)
					margin_container.add_theme_constant_override("margin_right", margin_value)
					margin_container.add_child(hbox_container)
					add_custom_control(margin_container)
					return true
		return false
	else:
		return false

## Needed to send and receive property changes.
class Direction2DEditorProperty extends EditorProperty:
	var editor_canvas : Direction2DEditorCanvas
	
	func _update_property() -> void:
		var value = get_edited_object().get(get_edited_property())
		editor_canvas.update_value(value if typeof(value) != TYPE_NIL else Vector2.RIGHT)

## Actually draws the interface and applies changes.
class Direction2DEditorCanvas extends Control:
	var current_value : Vector2 = Vector2.ZERO
	var tracking : bool = false
	var editor_property : EditorProperty
	func _init(editor_prop : EditorProperty, initial_value : Vector2):
		editor_property = editor_prop
		current_value = initial_value
		custom_minimum_size = Vector2(100, 100)
		size_flags_vertical = Control.SIZE_EXPAND
		queue_redraw()
	
	func _draw() -> void:
		tooltip_text = str(current_value)
		const LINE_WIDTH = 2.0
		var origin := size / 2
		var tip := origin + current_value * size / 2
		var tip_base := origin + current_value * 0.8 * size / 2
		draw_circle(origin, size.x / 2, Color.RED * 0.6, false, LINE_WIDTH)
		draw_line(origin + Vector2.LEFT * origin.x, origin + Vector2.RIGHT * origin.x, Color.RED * 0.8, LINE_WIDTH)
		draw_line(origin + Vector2.DOWN * origin.y, origin + Vector2.UP * origin.y, Color.RED * 0.8, LINE_WIDTH)
		draw_line(origin, tip, Color.GREEN, LINE_WIDTH)
		var tip_arrow_left := tip_base + current_value.rotated(90) * 10
		var tip_arrow_right := tip_base + current_value.rotated(-90) * 10
		draw_line(tip, tip_arrow_left, Color.GREEN, LINE_WIDTH)
		draw_line(tip, tip_arrow_right, Color.GREEN, LINE_WIDTH)
	
	func _gui_input(event: InputEvent) -> void:
		var mb := event as InputEventMouseButton
		if mb:
			if mb.is_pressed():
				tracking = true
			else:
				tracking = false
				editor_property.emit_changed(editor_property.get_edited_property(), current_value)
			
		var mm := event as InputEventMouse
		if mm and tracking:
			var new_value := mm.position - size / 2
			if not new_value.is_zero_approx():
				new_value = new_value.normalized()
				update_value(new_value)
	
	func update_value(value : Vector2):
		if current_value != value:
			current_value = value
			queue_redraw()

# Drives the Angle UI.
class Direction2DEditorUI extends VBoxContainer:
	var property : Direction2DEditorProperty
	var canvas : Direction2DEditorCanvas
	var angle_spinbox : SpinBox
	func _init(editor_property : Direction2DEditorProperty, editor_canvas : Direction2DEditorCanvas) -> void:
		property = editor_property
		canvas = editor_canvas
		canvas.draw.connect(_sync_with_canvas)
		angle_spinbox = SpinBox.new()
		angle_spinbox.min_value = -180
		angle_spinbox.max_value = 180
		angle_spinbox.step = 0.01
		angle_spinbox.value_changed.connect(_angle_spinbox_changed)
		add_child(_create_labeled_control("Angle", angle_spinbox))
	
	func _angle_spinbox_changed(angle : float):
		property.emit_changed(property.get_edited_property(), Vector2.from_angle(deg_to_rad(angle)))
	
	func _create_labeled_control(text : String, control : Control):
		var hbox := HBoxContainer.new()
		var label := Label.new()
		label.text = text
		hbox.add_child(label)
		hbox.add_child(control)
		return hbox
	
	func _sync_with_canvas():
		angle_spinbox.set_value_no_signal(rad_to_deg(canvas.current_value.angle()))
