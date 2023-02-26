extends Control

export var can_continue = false;

func _process(delta):
	if can_continue == true:
		if Input.is_action_just_pressed("interact"):
			get_tree().change_scene("res://Scenes/GameLevel.tscn")
