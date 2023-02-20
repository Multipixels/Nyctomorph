tool

extends Node2D

onready var Background = $Background
onready var BackgroundTrees = $BackgroundTrees
onready var Trees = $Trees
onready var BackDecals = $BackDecals
onready var Foreground = $Foreground

onready var LightMaterial = preload("res://Shaders/Materials/light_object.tres")
onready var GenericMaterial = preload("res://Shaders/Materials/generic.tres")

export(bool) var lighting_enabled = true
export(bool) var lighting_in_editor = false setget set_editor_lighting

func _ready() -> void:
	
	if Engine.editor_hint:
		reflect_editor_changes()
	else:
		if lighting_enabled:
			give_material(LightMaterial)
		else:
			give_material(GenericMaterial)

func give_material(material) -> void:
	Background.material = material
	BackgroundTrees.material = material
	Trees.material = material
	BackDecals.material = material
	Foreground.material = material
	
func set_editor_lighting(new_val):
	lighting_in_editor = new_val
	reflect_editor_changes()
	
func reflect_editor_changes():
	
	if Engine.editor_hint:
		if lighting_in_editor:
			give_material(LightMaterial)
		else:
			give_material(GenericMaterial)
