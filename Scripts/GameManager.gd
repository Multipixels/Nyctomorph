extends Node2D

var time_passed = 0;
var win_time = 300;

onready var timer = $DeathKnell
onready var light_timer = $LightsTimer
onready var second = $TwoSec

onready var time_ui_sprite = get_parent().get_node("UI/TimeUISprite")
onready var pauseUI = get_parent().get_node("UI/Pause");

onready var attack = load("res://Scenes/AttackLayer.tscn")

func _input(event):
	if event.is_action_pressed("pause"):
		Engine.time_scale = abs(Engine.time_scale - 1);
		get_tree().paused = !get_tree().paused;
		
		pauseUI.visible = !pauseUI.visible;

func _process(delta):
	
	time_passed += delta;
	
	time_ui_sprite.set_frame(int(time_passed) / 50);
	
	if time_passed > win_time:
		get_tree().change_scene("res://Scenes/WinMenu.tscn")
		

func _on_Monster_caught_player():
	timer.start()
	light_timer.start()


func _on_DeathKnell_timeout() -> void:
	var new_attack = attack.instance()
	get_parent().add_child(new_attack)
	second.start()
	


func _on_LightsTimer_timeout() -> void:
	for each in get_tree().get_nodes_in_group("Campfire"):
		each.queue_free()
		
	for each in get_tree().get_nodes_in_group("Top"):
		each.queue_free()
		
	for each in get_tree().get_nodes_in_group("Bot"):
		each.queue_free()
		
	for each in get_tree().get_nodes_in_group("UI"):
		each.visible = false
		
	for each in get_tree().get_nodes_in_group("Player"):
		each.visible = false
		
	for each in get_tree().get_nodes_in_group("Sound"):
		each.volume_db = -80;
		


func _on_OneSec_timeout() -> void:
	get_tree().change_scene("res://Scenes/DeadMenu.tscn")
