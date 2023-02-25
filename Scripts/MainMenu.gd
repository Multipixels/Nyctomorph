extends Control

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene("res://Scenes/GameLevel.tscn")
