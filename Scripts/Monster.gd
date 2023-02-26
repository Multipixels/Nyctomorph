extends Node2D

#Player needs to stay alive for 300 seconds.

#Campfire lasts 30 seconds per level. initial campfire lasts 60 seconds.
#this means player needs to find minimum 8 twigs.

#Monster doesn't start moving until 30 seconds into the game.
#Every 5 seconds it will move.
#(30-120) Roam: 4 actions, Hunt: 2 actions
#(120-180) Roam: 3 actions, Hunt: 3 actions, (starts at 18 actions)
#(180-240) Roam: 2 actions, Hunt: 4 actions,  (starts at 30 actions)
#(240-300) Roam: 1 action, Hunt: 5 actions    (starts at 42 actions)

onready var loom = load("res://Scenes/Loom.tscn")

var action_timer_default = 5;
var action_timer = 30;

var wondering_action_default = 4;
var wondering_action = wondering_action_default;

var hunting_action_default = 2;

var current_frame = 0
var current_floor = 0;

var total_actions = 0;

var player;

var rng = RandomNumberGenerator.new()

signal caught_player();

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0];
	
	if position.x >= 0:
		current_frame = int(position.x) / 48;
	elif position.x < 0:
		current_frame = int(position.x) / 48 - 1;
		
	if position.y >= 0:
		current_floor = int(position.y) / 168;
	elif position.y < 0:
		current_floor = int(position.y) / 168 - 1;
		
	position.x = 48 * current_frame + 24;
	position.y = 168 * current_floor + 48;

func _process(delta):
	action_timer -= delta
	
	if action_timer <= 0:
		monster_action();
		action_timer = action_timer_default;
		
	if total_actions >= 42:
		hunting_action_default = 5
		wondering_action_default = 1
	elif total_actions >= 30:
		hunting_action_default = 4
		wondering_action_default = 2
	elif total_actions >= 18:
		hunting_action_default = 3
		wondering_action_default = 3
		
	# if monster in same frame as player, game over.
	if Vector2.ZERO == Vector2(current_frame - player.current_frame, current_floor - player.current_floor):
		var creep = loom.instance()
		creep.global_position = player.global_position
		creep.global_position.y = current_floor*168 + 42
		get_parent().add_child(creep)
		emit_signal("caught_player");
		queue_free()
		#print("game over, monster is in same frame as player.")
		
func monster_action():
	var new_floor;
	var new_frame;
	var is_wondering;
	
	var enrage;
	
	var campfires = get_tree().get_nodes_in_group("Campfire");
	var player_torch = false;
	
	if player.torch_time_remaining > 0:
			player_torch = true;
	
	var distance_from_player = Vector2(current_frame - player.current_frame, current_floor - player.current_floor);
	var distance_from_campfires = [];
	
	var campfire_near_player = [];
	
	is_wondering = wondering_action <= wondering_action_default;
		
	#check all campfires. store distance. check if near player.
	for item in campfires:
		var the_campfire = Vector2(current_frame - item.current_frame, current_floor - item.current_floor);
		var player_campfire = Vector2(player.current_frame - item.current_frame, player.current_floor - item.current_floor)
		
		distance_from_campfires.append(the_campfire);
		
		if abs(player_campfire.x) <= 2 and abs(player_campfire.y) <= 2:
			campfire_near_player.append(true);
		else:
			campfire_near_player.append(false)
	
	enrage = false;
	
	new_frame = current_frame;
	new_floor = current_floor;

	var action_complete = false;
		
	# if no light in the world, game over
	if campfires == [] and player_torch == false:
		new_frame = player.current_frame;
		new_floor = player.current_floor;
		action_complete = true;
		print("no light in world");
	
	
	#if monster is within 5x5 of player...
	if action_complete != true and abs(distance_from_player.x) <= 2 and abs(distance_from_player.y) <= 2:
		action_complete = true;
		var direction;
		print("monster within 4x4 of player:");
		
		#if player near campfire, run away
		if true in campfire_near_player:
			direction = move_towards(distance_from_player) * -1;
			print("player near campfire, run away");
		
		#if player has torch, approach
		elif player_torch == true:
			direction = move_towards(distance_from_player);
			print("player has torch, approach");
			
		#if player has no torch and not near campfire, approach
		else:
			enrage = true;
			direction = move_towards(distance_from_player);
			print("hunt");
			
		new_frame += direction.x;
		new_floor += direction.y;
		
	#if monster is wondering...
	if action_complete == false and is_wondering:
		print("am wunder, ooo")
		action_complete = true;
		rng.randomize()
		new_frame += rng.randi_range(-1, 1);
		rng.randomize();
		new_floor += rng.randi_range(-1, 1);
		
	#if monster is within 5x5 of campfire...
	if action_complete == false:
		var index = 0;
		for fire in distance_from_campfires:
			if abs(fire.x) <= 2 and abs(fire.y) <= 2:
				print("monster within 4x4 of campfire:");
				print(campfires[index].name)
				if campfire_near_player[index] == false:
					action_complete = true;
					var direction;
					#approach campfire
					
					direction = move_towards(fire);
					new_frame += direction.x;
					new_floor += direction.y;
					print("player not near: approach campfire");
					
					break;
				print("but player is near");
			index+=1;
	
	# none of the above:
	if action_complete == false:
		var direction;
		if campfires != []:
			direction = move_towards(distance_from_campfires[0]);
		else:
			direction = move_towards(distance_from_player);
		new_frame += direction.x;
		new_floor += direction.y;
		print("none");
		#walk towards any campfire
	
	if new_frame >= -8 and new_frame <= 8:
		current_frame = new_frame
	
	if new_floor >= -5 and new_floor <= 5:
		current_floor = new_floor
		
	####################################################d################################################
	
	# update monster 2D position.
	position.x = 48 * current_frame + 24;
	position.y = 168 * current_floor + 48;
	
	action_timer = action_timer_default;
	if enrage: action_timer /= 2;
	
	wondering_action -= 1;
	if wondering_action <= 0:
		wondering_action = wondering_action_default + hunting_action_default;
	
	####################################################################################################
	
	#check for nearby fires to destroy
	
	for item in campfires:
		var the_campfire = Vector2(current_frame - item.current_frame, current_floor - item.current_floor);
		
		if the_campfire == Vector2.ZERO:
			print("destroy campfire")
			item.queue_free();
	
	print(position);
	
	
	
func move_towards(difference: Vector2):
	if difference.x > 0:
		return Vector2(-1, 0);
	elif difference.x < 0:
		return Vector2(1, 0);
		
	if difference.y > 0:
		return Vector2(0, -1);
	return Vector2(0, 1);


func get_distance_to_player():
	return abs(current_frame - player.current_frame) + abs(current_floor - player.current_floor)
