extends Node

# Signals
signal quest_accepted(quest: Quest)
signal quest_objective_updated(quest: Quest, objective: QuestObjective)
signal quest_completed(quest: Quest)
signal quests_updated()

# Quest Database & States
var quest_database: Dictionary = {}
var active_quests: Dictionary = {}
var completed_quests: Array[String] = []

func _ready() -> void:
	print("QuestManager: Initializing...")
	load_quest_database()
	# GameState is an autoload, let's wait a bit to ensure it is fully ready before loading quests
	call_deferred("load_from_game_state")

func load_quest_database() -> void:
	var path = "res://scripts/data/quests.json"
	if not FileAccess.file_exists(path):
		print("QuestManager: Warning, quests.json not found at ", path)
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var json_data = JSON.parse_string(content)
	
	if json_data is Dictionary:
		quest_database = json_data
		print("QuestManager: Successfully loaded ", quest_database.keys().size(), " quests from database.")
	else:
		print("QuestManager: Error parsing quests.json")

func accept_quest(quest_id: String) -> void:
	if not quest_database.has(quest_id):
		print("QuestManager: Quest ", quest_id, " not found in database.")
		return
		
	if active_quests.has(quest_id) or completed_quests.has(quest_id):
		print("QuestManager: Quest ", quest_id, " is already active or completed.")
		return
		
	var data = quest_database[quest_id]
	var quest = Quest.new()
	
	# Populate quest data
	quest.id = quest_id
	quest.title = data.get("title", "Untitled Quest")
	quest.description = data.get("description", "")
	quest.is_main_quest = bool(data.get("is_main_quest", false))
	quest.next_quest = data.get("next_quest", "")
	quest.rewards = data.get("rewards", {})
	quest.status = "active"
	
	# Populate objectives
	var objectives_data = data.get("objectives", [])
	for obj_data in objectives_data:
		var obj = QuestObjective.new()
		obj.id = obj_data.get("id", "")
		obj.type = obj_data.get("type", "")
		obj.description = obj_data.get("description", "")
		obj.target_city = obj_data.get("target_city", "")
		obj.target_resource = obj_data.get("target_resource", "")
		obj.target_qty = int(obj_data.get("target_qty", 0))
		obj.current_qty = 0
		obj.is_completed = false
		quest.objectives.append(obj)
		
	active_quests[quest_id] = quest
	print("QuestManager: Quest accepted: ", quest.title)
	
	emit_signal("quest_accepted", quest)
	emit_signal("quests_updated")
	save_to_game_state()
	
	# Trigger a check with current city/state immediately in case the player is already there
	if GameState.state.has("current_city") and GameState.state.current_city != "":
		notify_city_reached(GameState.state.current_city)

func notify_city_reached(city_name: String) -> void:
	# Track current city globally in state
	GameState.state["current_city"] = city_name
	GameState.save()
	
	process_event("reach_city", {"city_name": city_name})

func notify_goods_delivered(city_name: String, resource_name: String, qty: int) -> void:
	process_event("deliver_goods", {
		"city_name": city_name,
		"resource_name": resource_name,
		"qty": qty
	})

func notify_goods_collected(resource_name: String, qty: int) -> void:
	process_event("collect_goods", {
		"resource_name": resource_name,
		"qty": qty
	})

func notify_money_changed(money: int) -> void:
	process_event("earn_money", {
		"money": money
	})

func process_event(event_type: String, event_data: Dictionary) -> void:
	var changed = false
	var completed_this_run = []
	
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		var quest_changed = false
		
		for obj in quest.objectives:
			var old_val = obj.current_qty
			var old_status = obj.is_completed
			if obj.update_progress(event_type, event_data):
				quest_changed = true
				changed = true
				emit_signal("quest_objective_updated", quest, obj)
				
		if quest_changed:
			if quest.is_completed():
				completed_this_run.append(quest)
				
	if changed:
		save_to_game_state()
		emit_signal("quests_updated")
		
	for quest in completed_this_run:
		complete_quest(quest)

func complete_quest(quest: Quest) -> void:
	var quest_id = quest.id
	if not active_quests.has(quest_id):
		return
		
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	quest.status = "completed"
	
	print("QuestManager: Quest completed: ", quest.title)
	emit_signal("quest_completed", quest)
	
	# Process rewards
	claim_rewards(quest)
	
	# Handle quest chains
	if quest.next_quest != "":
		# Delay slightly to allow signals/UI to process the completion before accepting the next one
		call_deferred("accept_quest", quest.next_quest)
		
	save_to_game_state()
	emit_signal("quests_updated")

func claim_rewards(quest: Quest) -> void:
	var rewards = quest.rewards
	print("QuestManager: Claiming rewards for ", quest.title, ": ", rewards)
	
	# Check if trade scene is active
	var is_trade_active = false
	var city_scene = null
	
	if has_node("/root/SceneManager"):
		var sm = get_node("/root/SceneManager")
		if "city_scene" in sm and sm.city_scene != null:
			city_scene = sm.city_scene
			is_trade_active = true
			
	# Claim money reward
	if rewards.has("money"):
		var amt = int(rewards["money"])
		if is_trade_active and city_scene.has_node("Containers/TrainResourceContainer"):
			var train_res = city_scene.get_node("Containers/TrainResourceContainer")
			train_res.add_money(amt)
		else:
			# Directly update GameState
			if not GameState.state.has("money"):
				GameState.state["money"] = 1000
			GameState.state["money"] += amt
			GameState.save()
			
	# Claim wagon reward
	if rewards.has("wagon"):
		var wagon_name = rewards["wagon"]
		# Append to GameState train wagons list
		if not GameState.state.has("train"):
			GameState.state["train"] = {}
		if not GameState.state.train.has("wagons"):
			GameState.state.train["wagons"] = []
			
		GameState.state.train.wagons.append({
			"wagon_name": wagon_name,
			"cargo": []
		})
		GameState.save()
		
		# If trade scene is active, dynamically update active train
		if is_trade_active and city_scene.has_node("Containers/Trains") and city_scene.horizontal_train != null:
			city_scene.horizontal_train.add_wagon({
				"wagon_name": wagon_name,
				"cargo": []
			})

func save_to_game_state() -> void:
	var quests_state = {
		"active": {},
		"completed": completed_quests
	}
	
	for quest_id in active_quests:
		quests_state["active"][quest_id] = active_quests[quest_id].to_dict()
		
	GameState.state["quests"] = quests_state
	GameState.save()
	print("QuestManager: Saved quest state to GameState.")

func load_from_game_state() -> void:
	active_quests.clear()
	completed_quests.clear()
	
	if GameState.state.has("quests"):
		var quests_state = GameState.state["quests"]
		
		# Load completed
		var completed_list = quests_state.get("completed", [])
		for q_id in completed_list:
			completed_quests.append(String(q_id))
			
		# Load active
		var active_dict = quests_state.get("active", {})
		for q_id in active_dict:
			var quest = Quest.new()
			quest.from_dict(active_dict[q_id])
			active_quests[String(q_id)] = quest
			
		print("QuestManager: Loaded quest state. Active: ", active_quests.size(), ", Completed: ", completed_quests.size())
		
	# Brand new game! Start the first tutorial quest
	if active_quests.is_empty() and completed_quests.is_empty():
		print("QuestManager: No quest state found in GameState. Starting first tutorial quest.")
		accept_quest("quest_tutorial_1")
		
	emit_signal("quests_updated")
