extends Node2D

var time_passed = 0;
var win_time = 300;

onready var time_ui_sprite = get_parent().get_node("UI/TimeUISprite")

func _ready():
	Engine.time_scale = 1;

func _process(delta):
	time_passed += delta;
	
	time_ui_sprite.set_frame(int(time_passed) / 60);
	
	if time_passed > win_time:
		get_tree().change_scene("res://Scenes/WinMenu.tscn")
		

func _on_Monster_caught_player():
	print("game lost: reset scene")
	get_tree().change_scene("res://Scenes/DeadMenu.tscn")
	pass #lose game
