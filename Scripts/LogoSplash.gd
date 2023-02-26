extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func to_main_menu():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	
