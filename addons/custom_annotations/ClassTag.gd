extends GDScriptClassAnnotation
## ClassTag is a pure metadata annotation that
## comes with compile-time validation.
##
## It checks if the tag_name argument is listed in
## the global_class_tag_database.tres "ClassTagDatabase" resource,
## and emits an error if not found.
class_name ClassTag

var _tag_id : int

var class_tag_database : ClassTagDatabase = preload("res://addons/custom_annotations/global_class_tag_database.tres")

func _init(tag_name : StringName) -> void:
	var id = class_tag_database.tags.find(tag_name)
	if id < 0:
		error_message = "%s is not a valid entry in the global class tag database." % tag_name
		return
	_tag_id = id

func get_tag_name() -> StringName:
	return class_tag_database.tags[_tag_id]
