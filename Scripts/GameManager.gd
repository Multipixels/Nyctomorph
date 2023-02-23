extends Node2D

var time_passed = 0;
var win_time = 360;

func _ready():
	Engine.time_scale = 2;

func _process(delta):
	time_passed += delta;
	
	if time_passed > win_time:
		pass #win game
		

func _on_Monster_caught_player():
	print("game lost: reset scene")
	get_tree().change_scene("res://Scenes/DeadMenu.tscn")
	pass #lose game
