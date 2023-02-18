extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var t = 0;
var newPosition = position;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Player_move_frame(frame):
	t = 0
	newPosition.x = frame*48-48;
	

func _physics_process(delta):
	t += delta * 0.4

	position = position.linear_interpolate(newPosition, t)
