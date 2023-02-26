extends Sprite

export(int) var intensity := 0;


func _on_Timer_timeout() -> void:
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var frame_offset = Vector2(rng.randi_range(0, 48), rng.randi_range(0, 84))
	
	if intensity >= 0 and intensity <= 4:
		frame_offset += Vector2(96*intensity, 0)
	
	region_rect = Rect2(frame_offset.x, frame_offset.y, 48, 84)


func set_intensity(new_int: int) -> void:
	intensity = clamp(new_int, 0, 4)


func _on_Player_static_level(new_level) -> void:
	set_intensity(new_level)


func _on_Player_static_offset(is_offset) -> void:
	if is_offset: offset.x = 1
	else: offset.x = 0
		
