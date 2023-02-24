extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var sprite = $MainSprite
onready var torchLight = $TorchLight
onready var placeChecker = $PlaceChecker
onready var entranceChecker = $EntranceChecker

signal move_floor(flooor);

var current_frame = 0;
var current_floor = 0;

var motionHorizontal = 0;
var motionVertical = 0;
var motion = Vector2(0, 0);

export var playerSpeed = 25;
var direction = 1;

var canMove = true;
var canMoveTimer = 0.0;

var current_twigs = 0;
var max_twigs = 3;

var torch_time_remaining = 150;

onready var twig_scene = load("res://Scenes/Twig.tscn")
onready var campfire_scene = load("res://Scenes/Campfire.tscn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	canMoveTimer -= delta;
	torch_time_remaining -= delta;
	
	playerSpeed = 24 - 3 * current_twigs;
	animation_player.playback_speed = (24 / playerSpeed) * 1.1
	
	if canMoveTimer <= 0:
		canMove = true;
		
	if torch_time_remaining > 0:
		torchLight.enabled = true;
		max_twigs = 1
	else:
		torchLight.enabled = false;
		max_twigs = 3

func _physics_process(_delta):
	
	motionHorizontal = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"));
	motionVertical = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"));
	
	motion = Vector2(motionHorizontal, motionVertical).normalized()*playerSpeed;
	
	if (motion.distance_to(Vector2.ZERO) > sqrt(2) and canMove):
		
		var movement_velocity = move_and_slide(motion);
		sprite.global_position = (global_position.round() + Vector2(0, -15))
		torchLight.global_position = global_position.round()
		
		if movement_velocity.distance_to(Vector2.ZERO) > 0.01 :
			walk_animate(motion)
			
		else:
			idle_animate()
		
	else:
		idle_animate()
		
	if motion.x < 0 and canMove:
		sprite.flip_h = true
		torchLight.scale.x = -1
		placeChecker.position.x = -12
	elif motion.x > 0 and canMove:
		sprite.flip_h = false
		torchLight.scale.x = 1
		placeChecker.position.x = 12
	
	var last_collision = get_last_slide_collision();
	
	######################################################################################
	
	var playerAreas = entranceChecker.get_overlapping_areas();
	
	for item in playerAreas:
		if item.is_in_group("Top") and motion.y < 0:
			global_position += Vector2(item.send_to.x * 48, -item.send_to.y * (2*84) + 54)
		elif item.is_in_group("Bot") and motion.y > 0:
			global_position += Vector2(item.send_to.x * 48, item.send_to.y * (2*84) - 54)
		
	
	######################################################################################
	
	var bodies = placeChecker.get_overlapping_bodies();
	var areas = placeChecker.get_overlapping_areas();
	var items = bodies + areas;
	
	if Input.is_action_just_pressed("interact"):

		var action = true;
		
		for each in items:
			if each.is_in_group("Twig") and current_twigs < max_twigs:
				action = false;
				current_twigs += 1;
				each.queue_free();
				break;
				
		if action and current_twigs > 0:
			for body in items:
				if body.is_in_group("Campfire") and current_twigs < max_twigs:
					torch_time_remaining = 150;
					current_twigs -= 1;
					break;
	
	if Input.is_action_just_pressed("consume"):
		var action = true;
		
		if current_twigs > 0:
			for body in items:
				if body.is_in_group("Campfire"):
					action = false;
					body.add_fuel(1);
					current_twigs -= 1;
					break;
		
		if action and current_twigs > 0:
			
			var able = true
				
			for item in items:
				if not item.is_in_group("Twig"):
					able = false	
			
			if able:
				action = false;
				current_twigs -= 1;
				var droppedTwig = twig_scene.instance();
				get_parent().add_child(droppedTwig);
				
				var rng = RandomNumberGenerator.new()
				rng.randomize()
				var offset = Vector2(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
				
				droppedTwig.global_position = (placeChecker.global_position + offset).round();
	
		if action and torch_time_remaining > 0 and current_twigs == 0:
			var available = true
			var campfire = null
			
			for item in items:
				if not item.is_in_group("Twig"):
					available = false
				if item.is_in_group("Campfire"):
					campfire = item
				
			if available:	
				
				for item in items:
					item.queue_free()
				
				var droppedCampfire = campfire_scene.instance();
				get_parent().add_child(droppedCampfire);
				droppedCampfire.global_position = placeChecker.global_position.round();
				droppedCampfire.time_remaining = droppedCampfire.time_per_level*(len(items) + 1);
				droppedCampfire.update_info();
				torch_time_remaining = 0;
				
			elif campfire != null:
				
				campfire.add_fuel(torch_time_remaining/150)
				torch_time_remaining = 0
	
	######################################################################################

	if position.x >= 0 and (position.x / 48 - current_frame >= 1.02 or position.x / 48 - current_frame <= -0.02):
		current_frame = int(position.x) / 48;
	elif position.x < 0 and (position.x / 48 - 1 - current_frame >= 0.02 or position.x / 48 - 1 - current_frame <= -1.02):
		current_frame = int(position.x) / 48 - 1;
		
	if position.y >= 0 and (position.y / 168 - current_floor >= 1.02 or position.y / 168 - current_floor <= -0.02):
		current_floor = int(position.y) / 168;
		canMove = false;
		emit_signal("move_floor", current_floor);
		position.x = round(position.x);
		position.y = round(position.y);
		canMoveTimer = 0.75
	elif position.y < 0 and (position.y / 168 - 1 - current_floor >= 0.02 or position.y / 168 - 1- current_floor <= -1.02):
		current_floor = int(position.y) / 168 - 1;
		canMove = false;
		emit_signal("move_floor", current_floor);
		position.x = round(position.x);
		position.y = round(position.y);
		canMoveTimer = 0.75


func walk_animate(vec):
	
	var burden_level = current_twigs
	if torch_time_remaining > 0:
		burden_level += 1
	
	match burden_level:
		0: animation_player.play("walk")
		1: animation_player.play("walk1Stick")
		2: animation_player.play("walk2Stick")
		3: animation_player.play("walk3Stick")
		

func idle_animate():
	
	var burden_level = current_twigs
	if torch_time_remaining > 0:
		burden_level += 1
	
	match burden_level:
		0: animation_player.play("idle")
		1: animation_player.play("idle1Stick")
		2: animation_player.play("idle2Stick")
		3: animation_player.play("idle3Stick")


func _on_ArrowUp_body_entered(body):
	current_floor += 1;
	canMove = false;
	emit_signal("move_floor", current_floor);
	canMoveTimer = 1;
	
	position.y -= 148;


func _on_ArrowDown_body_entered(body):
	current_floor -= 1;
	canMove = false;
	emit_signal("move_floor", current_floor);
	canMoveTimer = 1;
	
	position.y += 148;
