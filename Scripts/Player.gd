extends KinematicBody2D

signal move_frame(frame);
signal move_floor(flooor);

var current_frame = 0;
var current_floor = 0;

var motionHorizontal = 0;
var motionVertical = 0;
var motion = Vector2(0, 0);
var previousMotion = Vector2(0, 0);

export var playerSpeed = 25;
var direction = 1;

var canMove = true;
var canMoveTimer = 0.0;

var current_twigs = 0;
var max_twigs = 3;
var is_holding_torch = false;

onready var twig_scene = load("res://Scenes/Twig.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	canMoveTimer -= delta;
	
	playerSpeed = 24 - 3 * current_twigs;
	
	if canMoveTimer <= 0:
		canMove = true;

func _physics_process(_delta):
	motionHorizontal = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"));
	motionVertical = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"));
	
	previousMotion = motion;
	motion = Vector2(motionHorizontal, motionVertical).normalized()*playerSpeed;
	
	if (motion != previousMotion):
		position.x = round(position.x);
		position.y = round(position.y);
	
	if (motion != Vector2(0, 0) and canMove):
		move_and_slide(motion);
	
	var last_collision = get_last_slide_collision();
	if last_collision != null:
		if Input.is_action_just_pressed("interact"):
			if last_collision.collider.is_in_group("Twig") and current_twigs < max_twigs:
				current_twigs += 1;
				get_last_slide_collision().collider.queue_free();
	
	if Input.is_action_just_pressed("consume"):
		var action = false;
		
		if current_twigs > 0:
			for body in $FireChecker.get_overlapping_bodies():
				if body.is_in_group("Campfire"):
					action = true;
					body.add_fuel();
					current_twigs -= 1;
					break;
		
		if !action and current_twigs > 0 and $TwigChecker.get_overlapping_bodies() == []:
			current_twigs -= 1;
			var droppedTwig = twig_scene.instance();
			get_parent().add_child(droppedTwig);
			droppedTwig.global_position = Vector2(global_position.x, global_position.y+2);
	
	
	
	
	
	if position.x >= 0 and (position.x / 48 - current_frame >= 1.02 or position.x / 48 - current_frame <= -0.02):
		current_frame = int(position.x) / 48;
		canMove = false;
		emit_signal("move_frame", current_frame);
		position.x = round(position.x);
		position.y = round(position.y);
		canMoveTimer = 0.75
	elif position.x < 0 and (position.x / 48 - 1 - current_frame >= 0.02 or position.x / 48 - 1 - current_frame <= -1.02):
		current_frame = int(position.x) / 48 - 1;
		canMove = false;
		emit_signal("move_frame", current_frame);
		position.x = round(position.x);
		position.y = round(position.y);
		canMoveTimer = 0.75
		
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
