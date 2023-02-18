extends Sprite

signal move_frame(frame);	

var move_timer_default = 1;
var move_timer = 0;

var current_frame = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down")) and move_timer <= 0:
		move_timer = move_timer_default;
		move();
		
	move_timer -= delta * 15;
	  
	
func move():
	if Input.is_action_pressed("move_right"):
	  position.x += 1;
	if Input.is_action_pressed("move_left"):
	  position.x -= 1;
	if Input.is_action_pressed("move_up"):
	  position.y -= 1;
	if Input.is_action_pressed("move_down"):
	  position.y += 1;

func _on_Area2D_area_entered(area):
	var to_frame = area.name.right(1).get_slice("-", 0);
	print(to_frame);
	
	if int(to_frame) == current_frame:
		emit_signal("move_frame", int(to_frame)+1);
		current_frame = int(to_frame)+1
		position.x += 6
	else:
		emit_signal("move_frame", int(to_frame));
		current_frame = int(to_frame)
		position.x -= 6
		
	
	
