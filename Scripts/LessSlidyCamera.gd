extends Camera2D

var level = 0;

func _physics_process(delta):
	global_position.y = level*168 + 42;
	if position.y == 0:
		Camera2D.smoothing = false;


func _on_Player_move_floor(flooor):
	smoothing_enabled = true;
	level = flooor;
