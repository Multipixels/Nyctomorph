tool

extends "res://Scripts/ShaderChanger.gd"

export(bool) var show_in_editor = false setget show_in_editor_set

func _ready() -> void:
	if Engine.editor_hint:
		reflect_editor_changes()
	else:
		queue_free()
		
func _input(event):
	pass
		
func show_in_editor_set(new_value):
	show_in_editor = new_value
	reflect_editor_changes()
		
func current_set(new_value):
	shader = new_value
	reflect_editor_changes()
		
func reflect_editor_changes():
	if show_in_editor:
		select_shader(shader)
	else:
		select_shader(null)
	
func change_shader(new_val):
	shader = new_val
	reflect_editor_changes()
