extends KinematicBody2D

signal move_frame(frame);

var current_frame = 0;

var motionHorizontal = 0;
var motionVertical = 0;
var motion = Vector2(0, 0);
var previousMotion = Vector2(0, 0);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	pass

func _physics_process(delta):
	motionHorizontal = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"));
	motionVertical = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"));
	
	previousMotion = motion;
	motion = Vector2(motionHorizontal, motionVertical).normalized()*12;
	
	if (motion != previousMotion):
		position.x = round(position.x);
		position.y = round(position.y);
	
	if (motion != Vector2(0, 0)):
		move_and_slide(motion);
		
	if position.x >= 0 and int(position.x) / 48 != current_frame:
		current_frame = int(position.x) / 48;
		emit_signal("move_frame", current_frame);
	elif position.x < 0 and int(position.x) / 48 - 1 != current_frame:
		current_frame = int(position.x) / 48 - 1;
		emit_signal("move_frame", current_frame);
