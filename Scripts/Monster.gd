extends Node2D

var action_timer_default = 10;
var action_timer = action_timer_default;

var wondering_switch_timer_default = 30;
var wondering_switch_timer = wondering_switch_timer_default;

var current_frame = 0
var current_floor = 0;

var player;

var is_wondering = true;
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
	if Input.is_action_just_pressed("light_toggle"):
		action_timer = 0;
	
	#action_timer -= delta
	wondering_switch_timer -= delta
	
	if action_timer <= 0:
		monster_action();
		action_timer = action_timer_default;
		
	if wondering_switch_timer <= 0:
		is_wondering = !is_wondering;
		wondering_switch_timer = wondering_switch_timer_default;
		
	# if monster in same frame as player, game over.
	if Vector2.ZERO == Vector2(current_frame - player.current_frame, current_floor - player.current_floor):
		emit_signal("caught_player");
		#print("game over, monster is in same frame as player.")
		
func monster_action():
	var enrage = false;
	var campfires = get_tree().get_nodes_in_group("Campfire");
	var player_torch = false;
	
	
	if player.torch_time_remaining > 0:
		player_torch = true;
		
	var distance_from_player = Vector2(current_frame - player.current_frame, current_floor - player.current_floor);
	var distance_from_campfires = [];
	
	var campfire_near_player = [];
	
	#check all campfires. store distance. check if near player.
	for item in campfires:
		var the_campfire = Vector2(current_frame - item.current_frame, current_floor - item.current_floor);
		var player_campfire = Vector2(player.current_frame - item.current_frame, player.current_floor - item.current_floor)
		
		distance_from_campfires.append(the_campfire);
		
		if abs(player_campfire.x) <= 3 and abs(player_campfire.y) <= 3:
			campfire_near_player.append(true);
		else:
			campfire_near_player.append(false)
		
	#############################################################################################
		
	var action_complete = false;
		
	# if no light in the world, game over
	if campfires == [] and player_torch == false:
		current_frame = player.current_frame;
		current_floor = player.current_floor;
		print("no light in world");
	
	
	#if monster is within 4x4 of player...
	if abs(distance_from_player.x) <= 3 and abs(distance_from_player.y) <= 3:
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
			
		current_frame += direction.x;
		current_floor += direction.y;
		
	#if monster is wondering...
	if action_complete == false and is_wondering:
		print("am wunder, ooo")
		action_complete = true;
		rng.randomize()
		current_frame += rng.randi_range(-1, 1);
		rng.randomize();
		current_floor += rng.randi_range(-1, 1);
		
	#if monster is within 4x4 of campfire...
	if action_complete == false:
		var index = 0;
		for fire in distance_from_campfires:
			if abs(fire.x) <= 3 and abs(fire.y) <= 3:
				print("monster within 4x4 of campfire:");
				print(campfires[index].name)
				if campfire_near_player[index] == false:
					action_complete = true;
					var direction;
					#approach campfire
					
					direction = move_towards(fire);
					current_frame += direction.x;
					current_floor += direction.y;
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
		current_frame += direction.x;
		current_floor += direction.y;
		print("none");
		#walk towards any campfire
		
	####################################################d################################################
	
	# update monster 2D position.
	position.x = 48 * current_frame + 24;
	position.y = 168 * current_floor + 48;
	
	action_timer = action_timer_default;
	if enrage: action_timer /= 2;
	
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

