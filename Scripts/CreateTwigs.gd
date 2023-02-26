extends TileMap

onready var twig = load("res://Scenes/Twig.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	addObjects();


func addObjects():
	var usedCells = get_used_cells()

	for i in usedCells.size():
		var object = get_cellv(usedCells[i])

		if object == 0 :
			var twig_instance = twig.instance()
			add_child(twig_instance)
			twig_instance.position = map_to_world(usedCells[i])

	clear()
