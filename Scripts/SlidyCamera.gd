extends Camera2D

onready var newPosition = position;
var t = 0;

func _physics_process(delta):
	t += delta * 0.4\
	
	position = position.linear_interpolate(newPosition, t)

func _on_Player_move_frame(frame):
	t = 0
	newPosition.x = frame*48+24;
	
func _on_Player_move_floor(flooor):
	t=0
	newPosition.y = (flooor - 5) * - 168 + 42;
