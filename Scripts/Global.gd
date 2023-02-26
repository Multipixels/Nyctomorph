extends Node

var current_shader = null

func _ready() -> void:
	Engine.time_scale = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
