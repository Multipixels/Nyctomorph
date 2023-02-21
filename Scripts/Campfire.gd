extends StaticBody2D

export var light_level = 3;
export var time_remaining = 380;
export var time_per_level = 100;

var light_materials;
var light_mat3 = preload("res://Sprites/Lights/CampfireLightLarge.png")
var light_mat2 = preload("res://Sprites/Lights/CampfireLightMed.png")
var light_mat1 = preload("res://Sprites/Lights/CampfireLightSmall.png")

func _ready():
	light_materials = [light_mat1, light_mat2, light_mat3];

func _process(delta):
	time_remaining -= delta;
	
	if light_level != int(time_remaining+time_per_level) / time_per_level:
		if int(time_remaining+time_per_level) / time_per_level > 3:
			light_level = 3;
		elif int(time_remaining+time_per_level) / time_per_level < 0:
			light_level = 0
		else:
			light_level = int(time_remaining+time_per_level) / time_per_level;
		
		switch_texture();

func add_fuel(units):
	if time_remaining < 0:
		time_remaining = 0;
	time_remaining += (time_per_level*units);

func switch_texture():
	if light_level == 0:
		$CampfireLight.hide();
	else:
		$CampfireLight.show();
		$CampfireLight.texture = light_materials[light_level-1];
