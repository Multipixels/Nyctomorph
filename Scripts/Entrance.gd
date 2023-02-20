extends Area2D

enum LOCATION { TOP, BOTTOM };


export(Vector2) var send_to: Vector2;
export(LOCATION) var placement;


func _on_Entrance_body_entered(body: Node) -> void:
	if send_to:
		match placement:
			LOCATION.TOP:
				body.global_position = global_position + Vector2(send_to.x * 48, send_to.y * (2*84) + 64)
			LOCATION.BOTTOM:
				body.global_position = global_position + Vector2(send_to.x * 48, send_to.y * (2*84) - 64)
