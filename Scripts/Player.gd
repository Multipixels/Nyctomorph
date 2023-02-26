extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var fire_animation_player = $FireAnimationPlayer
onready var sprite = $MainSprite
onready var torchLight = $TorchLight
onready var torchSprite = $TorchLightSprite
onready var placeChecker = $PlaceChecker
onready var entranceChecker = $EntranceChecker
onready var audio_player = $Sounds

onready var fuelTorch = get_parent().get_parent().get_node("UI/FuelTorch")
onready var drop = get_parent().get_parent().get_node("UI/Drop")
onready var place = get_parent().get_parent().get_node("UI/Place")
onready var pickup = get_parent().get_parent().get_node("UI/PickUp")
onready var fuel = get_parent().get_parent().get_node("UI/Fuel")

signal move_floor(flooor);
signal send_tip(tip);

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

var torch_time_remaining = 0;
var max_torch_time = 45;

onready var twig_scene = load("res://Scenes/Twig.tscn")
onready var campfire_scene = load("res://Scenes/Campfire.tscn")

onready var fuel_sound = load("res://Audio/fuel.mp3")
onready var invalid_sound = load("res://Audio/invalid.mp3")
onready var pickup_sound = load("res://Audio/pickup.mp3")
onready var place_sound = load("res://Audio/place.mp3")
onready var down_sound = load("res://Audio/goDown.mp3")
onready var up_sound = load("res://Audio/goUp.mp3")

var isTooLate = false;

var player_find_sticks = false; # I need fuel for this fire
var player_in_dark = false; # I need some light
var player_relocate = false; # This looks like a good spot for a new campfire
var player_near_monster = false; # I feel like something is watching me...

var campfires;

signal static_level(new_level)
var static_level = 0;
signal static_offset(offset)

func _ready():
	player_find_sticks = true;
	emit_signal("send_tip", 1)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	canMoveTimer -= delta;
	torch_time_remaining -= delta;
	
	playerSpeed = 24 - 3 * current_twigs;
	animation_player.playback_speed = (24 / playerSpeed) * 1.1 * Engine.time_scale;
	
	
	
	if !player_near_monster:
		if static_level >= 2:
			player_near_monster = true;
			emit_signal("sent_tip", 4);
	
	if canMoveTimer <= 0:
		canMove = true;
		
	if torch_time_remaining > 0:
		torchLight.enabled = true;
		max_twigs = 1
		
		if torch_time_remaining > (max_torch_time/3)*2:
			fire_animation_player.play("FireLarge")
		elif torch_time_remaining > (max_torch_time/3)*1:
			fire_animation_player.play("FireMed")
		else:
			fire_animation_player.play("FireSmall")
		
	else:
		torchLight.enabled = false;
		fire_animation_player.play("NoFire")
		max_twigs = 3
		
	for each in get_tree().get_nodes_in_group("Monster"):
		var level = 5 - (int(each.get_distance_to_player()))
		static_level = level;
		emit_signal("static_level", level)
		emit_signal("static_offset", int(round(global_position.x))%2)

func _physics_process(_delta):
	
	motionHorizontal = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"));
	motionVertical = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"));
	
	motion = Vector2(motionHorizontal, motionVertical).normalized()*playerSpeed;
	
	if (motion.distance_to(Vector2.ZERO) > sqrt(2) and canMove):
		
		var movement_velocity = move_and_slide(motion);
		sprite.global_position = (global_position.round() + Vector2(0, -15))
		torchLight.global_position = global_position.round()
		
		if movement_velocity.distance_to(Vector2.ZERO) > 0.01 and Engine.time_scale:
			walk_animate(motion)
			
		else:
			idle_animate()
		
	else:
		idle_animate()
		
	if motion.x < 0 and canMove and Engine.time_scale:
		sprite.flip_h = true
		torchSprite.scale.x = -1
		torchLight.scale.x = -1
		placeChecker.position.x = -12
	elif motion.x > 0 and canMove and Engine.time_scale:
		sprite.flip_h = false
		torchSprite.scale.x = 1
		torchLight.scale.x = 1
		placeChecker.position.x = 12
	
	var last_collision = get_last_slide_collision();
	
	######################################################################################
	
	var playerAreas = entranceChecker.get_overlapping_areas();
	
	for item in playerAreas:
		if item.is_in_group("Top") and motion.y < 0:
			current_floor -= 1;
			play_sound(up_sound);
			canMove = false;
			emit_signal("move_floor", current_floor);
			canMoveTimer = 0;
			position.y += -114;
		elif item.is_in_group("Bot") and motion.y > 0:
			current_floor += 1;
			play_sound(down_sound);
			canMove = false;
			emit_signal("move_floor", current_floor);
			canMoveTimer = 0;
			position.y += 114;
		
	
	######################################################################################
	
	var bodies = placeChecker.get_overlapping_bodies();
	var areas = placeChecker.get_overlapping_areas();
	var items = bodies + areas;
	
	var tooltips = []
	var canPlace = true;
	
	for item in items:
		if not item.is_in_group("Twig"):
			canPlace = false;
	
	if canPlace and torch_time_remaining > 0 and current_twigs == 0:
		tooltips.append(3)
	elif canPlace and current_twigs >= 1:
		tooltips.append(2)
	
	
	for each in items:
		
		if current_twigs >= 1 and current_twigs <= 2:
			if each.is_in_group("Campfire"):
				tooltips = [1]
				break;
		elif current_twigs == 3:
			if each.is_in_group("Campfire"):
				tooltips = [5];
			
		if each.is_in_group("Campfire") and torch_time_remaining > 0:
			tooltips.append(5)
			tooltips.erase(3);
		elif (current_twigs <= 2 and torch_time_remaining < 0) or (torch_time_remaining > 0 and current_twigs != 1):
			if each.is_in_group("Twig"):
				tooltips.append(4)
				
	
	
	tooltip(tooltips);
	
	if Input.is_action_just_pressed("interact") and !isTooLate:

		var action = true;
		
		for each in items:
			
			if action and current_twigs > 0:
				if each.is_in_group("Campfire") and current_twigs < max_twigs:
					action = false;
					torch_time_remaining = max_torch_time;
					play_sound(fuel_sound);
					current_twigs -= 1;
					break;
			
			if each.is_in_group("Twig") and current_twigs < max_twigs:
				action = false;
				current_twigs += 1;
				play_sound(pickup_sound);
				each.queue_free();
				break;
			
		if action:
			play_sound(invalid_sound);
				
	if Input.is_action_just_pressed("consume") and !isTooLate:
		var action = true;
		
	
		if current_twigs > 0:
			for body in items:
				if body.is_in_group("Campfire"):
					action = false;
					body.add_fuel(1);
					play_sound(fuel_sound);
					current_twigs -= 1;
					break;
		
		if action and current_twigs > 0:
			if canPlace == false:
				play_sound(invalid_sound);
			
			var able = true
				
			for item in items:
				if not item.is_in_group("Twig"):
					able = false	
			
			if able:
				action = false;
				current_twigs -= 1;
				play_sound(place_sound);
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
				action = false;
				play_sound(place_sound);
				get_parent().add_child(droppedCampfire);
				droppedCampfire.global_position = placeChecker.global_position.round();
				droppedCampfire.time_remaining = droppedCampfire.time_per_level*(len(items) + 1);
				droppedCampfire.update_info();
				torch_time_remaining = 0;
				
			elif campfire != null:
				
				campfire.add_fuel(torch_time_remaining/max_torch_time)
				action = false;
				play_sound(fuel_sound);
				torch_time_remaining = 0
				
		if action:
			play_sound(invalid_sound);
	
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
		
	if !player_in_dark or !player_relocate:
		campfires = get_tree().get_nodes_in_group("Campfire");
		var campfire_near_player = []
		
		for item in campfires:
			var the_campfire = Vector2(current_frame - item.current_frame, current_floor - item.current_floor);
			
			
			if abs(the_campfire.x) <= 1 and abs(the_campfire.y) <= 1:
				campfire_near_player.append(true);
			else:
				campfire_near_player.append(false);
				
		if not true in campfire_near_player and not player_in_dark and torch_time_remaining <= 0:
			player_in_dark = true;
			emit_signal("send_tip", 2);
			
		if not true in campfire_near_player and not player_relocate and torch_time_remaining > 0 and current_twigs > 0:
			player_relocate = true;
			emit_signal("sent_tip", 3);


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

func tooltip(value):
	fuelTorch.hide()
	drop.hide()
	place.hide()
	pickup.hide()
	fuel.hide()
	
	for each in value:
		match each:
			1:
				fuelTorch.show()
			2:
				drop.show()
			3:
				place.show()
			4:
				pickup.show()
			5:
				fuel.show()

func play_sound(sound):
	audio_player.stop();
	audio_player.set_stream(sound)
	audio_player.play(0);
