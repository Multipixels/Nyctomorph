extends KinematicBody2D

signal move_frame(frame);

var current_frame = 0;

var motionHorizontal = 0;
var motionVertical = 0;
var motion = Vector2(0, 0);
var previousMotion = Vector2(0, 0);

var playerSpeed = 15;
var direction = 1;

var canMove = true;
var canMoveTimer = 0.0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	canMoveTimer -= delta;
	
	if canMoveTimer <= 0:
		canMove = true;
		
	if Input.is_action_just_pressed("light_toggle"):
		if $TorchLight.is_visible():
			$TorchLight.hide();
		else:
			$TorchLight.show();

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
