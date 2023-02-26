tool

extends CanvasLayer

# ------ Values and preloads

enum SHADER {
	NORMAL,
	GREY,
	GREEN
};

onready var NormalShader = preload("res://Shaders/NormalShader.tres");
onready var GreyShader = preload("res://Shaders/GreyShader.tres");
onready var GreenShader = preload("res://Shaders/GreenShader.tres");

onready var ShaderOverlay = $ShaderOverlay

export(SHADER) var shader = SHADER.NORMAL setget change_shader
export(bool) var show_in_editor = false setget show_in_editor_set


# ------ Engine functions:


func _ready() -> void:
	
	if Global.current_shader != null:
		shader = Global.current_shader
	else:
		Global.current_shader = shader
	
	select_shader(shader);
	reflect_editor_changes()


func _input(event):
	
	if event.is_action_pressed("change_pallete"):
		shader = cycle_enum(shader);
		Global.current_shader = shader
		select_shader(shader);


# ------ Non-engine functions:


func select_shader(shader) -> void:
	
	match shader:
		SHADER.NORMAL:
			ShaderOverlay.show()
			ShaderOverlay.material = NormalShader
		SHADER.GREY:
			ShaderOverlay.show()
			ShaderOverlay.material = GreyShader
		SHADER.GREEN:
			ShaderOverlay.show()
			ShaderOverlay.material = GreenShader
		_:
			ShaderOverlay.hide()


func cycle_enum(shader) -> int:
	match shader:
		SHADER.NORMAL:
			return SHADER.GREY
		SHADER.GREY:
			return SHADER.GREEN
		SHADER.GREEN:
			return SHADER.NORMAL
			
	return 0
		
		
func change_shader(new_val) -> void:
	shader = new_val
	reflect_editor_changes()
	
	
func show_in_editor_set(new_value):
	show_in_editor = new_value
	reflect_editor_changes()
	
	
func reflect_editor_changes() -> void:
	if Engine.editor_hint:
		if show_in_editor:
			select_shader(shader)
		else:
			select_shader(null)
		
