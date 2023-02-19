extends Node

onready var NormalShader = $NormalShader;
onready var GreyShader = $GreyShader;
onready var GreenShader = $GreenShader;

enum SHADER {
	NORMAL,
	GREY,
	GREEN
};

export(SHADER) var shader = SHADER.NORMAL setget change_shader

func _ready() -> void:
	select_shader(shader);

func _input(event):
	
	if event.is_action_pressed("change_pallete"):
		shader = cycle_enum(shader);
		select_shader(shader);

func select_shader(shader) -> void:
	
	NormalShader.hide();
	GreyShader.hide();
	GreenShader.hide();
	
	match shader:
		SHADER.NORMAL:
			NormalShader.show()
		SHADER.GREY:
			GreyShader.show()
		SHADER.GREEN:
			GreenShader.show()

func cycle_enum(shader) -> int:
	match shader:
		SHADER.NORMAL:
			return SHADER.GREY
		SHADER.GREY:
			return SHADER.GREEN
		SHADER.GREEN:
			return SHADER.NORMAL
			
	return 0
		
func change_shader(new_val):
	shader = new_val
