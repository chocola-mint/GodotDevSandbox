@tool
extends EditorPlugin

var plugins : Array

func _enter_tree() -> void:
	plugins = [ 
		preload("res://addons/custom_annotations/ExportInputMapActionIndexEditor.gd").new(),
		preload("res://addons/custom_annotations/ExportDirection2DEditor.gd").new(),
		preload("res://addons/custom_annotations/ToolButtonEditor.gd").new(),
	]
	
	for plugin in plugins:
		add_inspector_plugin(plugin)

func _exit_tree() -> void:
	for plugin in plugins:
		remove_inspector_plugin(plugin)
	plugins.clear()
