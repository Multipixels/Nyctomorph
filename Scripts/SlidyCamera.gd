extends Camera2D

func _on_Player_move_frame(frame):
	position.x = frame*48+24;
	
func _on_Player_move_floor(level):
	position.y = level*168 + 42;
