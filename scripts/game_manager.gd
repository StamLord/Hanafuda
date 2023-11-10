extends Node

enum SUITE {PINE, PLUM, CHERRY, WISTERIA, IRIS, PEONY, CLOVER, GRASS, CHRYSANTHEMUM, MAPLE, WILLOW, PAULOWNIA}
enum TYPE {BRIGHT, RIBBON, ANIMAL, CHAFF}

# Constants
const animals = [[1,0],[3,0],[4,0],[5,0],[6,0],[7,1],[8,0],[9,0],[10,1]]
const ribbons = [[0,1],[1,1],[2,1],[3,1],[4,1],[5,1],[6,1],[8,1],[9,1],[10,2]]
const brights = [[0,0],[2,0],[7,0],[10,0],[11,0]]

const bright_yaku = {
	"Five Bright" : {
		"points" : 15,
		"count" : 5,
	},
	"Four Bright" : {
		"points" : 8,
		"count" : 4,
		"exclude" : [[10,0]]
	},
	"Rainy Four Bright" : {
		"points" : 7,
		"count" : 4,
		"include" : [[10,0]]
	},
	"Three Bright" : {
		"points" : 6,
		"count" : 3,
		"exclude" : [[10,0]]
	}
}

const animal_yaku = {
	"Boar Deer Butterfly" : {
		"points" : 5,
		"count" : 3,
		"include" : [[5,0], [6,0], [9,0]],
		"extra_points" : true
	},
	"Animals" : {
		"points" : 1,
		"count" : 5,
		"extra_points" : true
	}
}

const ribbon_yaku = {
	"Poetry + Blue Ribbons" : {
		"points" : 5,
		"count" : 6,
		"include" : [[0,1],[1,1],[2,1],[5,1],[8,1],[9,1]],
		"extra_points" : true
	},
	"Poetry Ribbons" : {
		"points" : 5,
		"count" : 3,
		"include" : [[0,1],[1,1],[2,1]],
		"extra_points" : true
	},
	"Blue Ribbons" : {
		"points" : 5,
		"count" : 3,
		"include" : [[5,1],[8,1],[9,1]],
		"extra_points" : true
	},
	"Ribbons" : {
		"points" : 1,
		"count" : 5,
		"extra_points" : true
	}
}

const chaff_yaku = {
	"Chaff" : {
		"points" : 1,
		"count" : 10,
		"extra_points" : true
	}
}

const moon_viewing_sake = {
	"name" : "Moon Viewing Sake",
	"points" : 5
}

const sakura_viewing_sake = {
	"name" : "Sakura Viewing Sake",
	"points" : 5
}

# Configurable
@export var animation_speed = 0.2
@export var turn_glow_speed = 0.2

@export var yaku_color_schemes = {
	"Default" : {"color" : "ffffff", "outline_color" : "000000"},
	"Moon Viewing Sake" : {"color" : "fbfbfb", "outline_color" : "2c3749"},
	"Sakura Viewing Sake" : {"color" : "feafd0", "outline_color" : "be3749"}
}

# References
var card_visual_path = preload("res://scenes/card_visual.tscn")

@onready var player_glow = %player_glow
@onready var enemy_glow = %enemy_glow
@onready var sakura_glow = %sakura_glow
@onready var moon_glow = %moon_glow
@onready var moon_sprite = %moon_sprite

@onready var sakura_particles = %sakura_burst
@onready var rain_particles = %rain

@onready var control = $CanvasLayer/Control

@onready var player_points_label = %player_points/points
@onready var enemy_points_label = %enemy_points/points

@onready var deck_parent = %deck

@onready var field = %field
@onready var enemy_hand = %enemy_hand
@onready var player_hand = %player_hand

@onready var player_chaffs = %player_chaffs
@onready var player_animals = %player_animals
@onready var player_ribbons = %player_ribbons
@onready var player_brights = %player_brights

@onready var enemy_chaffs = %enemy_chaffs
@onready var enemy_animals = %enemy_animals
@onready var enemy_ribbons = %enemy_ribbons
@onready var enemy_brights = %enemy_brights

@onready var yaku_popup = %yaku_popup
@onready var yaku_name = %yaku_name
@onready var yaku_points = %yaku_points

@onready var yaku_summary = %yaku_summary
@onready var yaku_summary_container = %yaku_summary/v_container

@onready var win_screen = %win_screen
@onready var win_text = %win_screen/win_text

# Game Variables
var round = 0
var max_round = 3
var current_player = 0

var player_points = 0
var enemy_points = 0

var deck : Array

var awaiting_input = false
var selected_card = null

func create_deck():
	deck.clear()
	for i in range(12):
		for j in range(4):
			deck.append(
				{
					"suite" : i,
					"number" : j
				})
	

func shuffle_deck():
	randomize()
	deck.shuffle()
	

func start_round():
	create_deck()
	shuffle_deck()
	
	# Fake table
#	await add_card({"suite" : 4, "number" : 0}, enemy_hand)
#	await add_card({"suite" : 2, "number" : 0}, field) # Sakura
#	await add_card({"suite" : 7, "number" : 0}, field) # Moon
#	await add_card({"suite" : 8, "number" : 0}, field) # Sake
#	await add_card({"suite" : 2, "number" : 1}, player_hand) # Sakura match
#	await add_card({"suite" : 8, "number" : 1}, player_hand) # Sake match
#	await add_card({"suite" : 7, "number" : 1}, player_hand) # Moon match
#	update_table()
#	return
	
	for i in range(4):
		await add_card(draw_card(), enemy_hand)
		await add_card(draw_card(), enemy_hand)
		
		await add_card(draw_card(), field)
		await add_card(draw_card(), field)
		
		await add_card(draw_card(), player_hand)
		await add_card(draw_card(), player_hand)
	
	update_table()
	
	if current_player == 1:
		cpu_turn()
	

func draw_card():
	var card = deck.pop_front()
	return card
	

func create_card_object(card):
	var card_object = card_visual_path.instantiate()
	deck_parent.add_child(card_object)
	
	var button = card_object.get_node("button")
	button.disabled = true
	button.pressed.connect(card_select.bind(card_object))
	button.button_down.connect(card_press_down.bind(card_object))
	button.button_up.connect(card_press_up.bind(card_object))
	
	card_object.set_card(card)
	return card_object
	

func add_card(card, hand):
	var card_object = create_card_object(card)
	await move_card(card_object, hand)
	

func _ready():
	start_round()
	

func update_points(points, amount):
	points.text = str(amount)
	

func cpu_turn():
	# Pretend to think
	await get_tree().create_timer(1).timeout
	# Select best card
	card_select(cpu_select(enemy_hand.get_children(), enemy_chaffs, enemy_ribbons, enemy_animals, enemy_brights))
	

func end_turn():
	current_player += 1
	current_player %= 2
	
	update_table()
	
	if current_player == 1:
		cpu_turn()
	

func end_round():
	round += 1
	
	# Clear board
	queue_free_children(player_hand)
	queue_free_children(enemy_hand)
	queue_free_children(field)
	
	queue_free_children(player_chaffs)
	queue_free_children(player_ribbons)
	queue_free_children(player_animals)
	queue_free_children(player_brights)
	
	queue_free_children(enemy_chaffs)
	queue_free_children(enemy_ribbons)
	queue_free_children(enemy_animals)
	queue_free_children(enemy_brights)
	
	# Start new round
	if round < max_round:
		start_round()
	else:
		end_game()
	

func end_game():
	# Stop turn glow
	if current_player == 0:
		animate_glow(player_glow, Vector2(1,1), Vector2(0,0))
	else:
		animate_glow(enemy_glow, Vector2(1,1), Vector2(0,0))
	
	var winner = -1 # Draw
	win_text.text = "DRAW"
	
	if player_points > enemy_points:
		winner = 0 # Player wins
		win_text.text = "PLAYER WINS!"
	elif enemy_points > player_points:
		winner = 1 # Enemy wins
		win_text.text = "ENEMY WINS!"
	
	# Show end screen
	win_screen.visible = true
	
	# Next round starts with winner
	current_player = winner
	
func update_glow():
	if current_player == 0:
		animate_glow(player_glow, Vector2(1,0), Vector2(1,1))
		enemy_glow.visible = false
	else:
		animate_glow(enemy_glow, Vector2(1,0), Vector2(1,1))
		player_glow.visible = false
	

func show_sakura_glow():
	sakura_particles.emitting = true
	await animate_glow(sakura_glow, Vector2(10,10), Vector2(1,1))
	await get_tree().create_timer(3).timeout
	await animate_glow(sakura_glow, Vector2(1,1), Vector2(10,10))
	sakura_particles.emitting = false
	sakura_glow.visible = false
	
func show_moon_glow():
	# Move in
	animate_glow(moon_glow, Vector2(1,0), Vector2(1,1))
	await animate_image(moon_sprite, moon_sprite.global_position - Vector2(0, 600), moon_sprite.global_position)
	
	# Wait
	await get_tree().create_timer(2).timeout
	
	# Move out
	await animate_image(moon_sprite, moon_sprite.global_position, moon_sprite.global_position - Vector2(0, 600))
	await animate_glow(moon_glow, Vector2(1,1), Vector2(1,0))
	moon_glow.visible = false
	moon_sprite.visible = false
	

func show_rain():
	rain_particles.emitting = true
	await get_tree().create_timer(3).timeout
	rain_particles.emitting = false
	

func show_summary(yaku):
	# Array of arrays: [[label1, label2], [label3, label4]]
	var lines = []
	
	# Clear all labels
	for child in yaku_summary_container.get_children():
		var label = child.get_node("Label")
		var label2 = child.get_node("Label2")
		
		# If both exist, add pair
		if label and label2:
			lines.append([label, label2])
		
		if label:
			label.text = ""
		if label2:
			label2.text = ""
	
	# Display summary
	yaku_summary.visible = true
	
	var total_points = 0
	
	# Fill in yaku
	var i = 0
	for y in yaku:
		lines[i][0].text = y[0]
		lines[i][1].text = str(y[1])
		
		total_points += y[1]
		
		i += 1
		
		await get_tree().create_timer(1).timeout
	
	# Add multipliers
	if total_points >= 7:
		total_points *= 2
		lines[lines.size()-2][0].text = "Over 7"
		lines[lines.size()-2][1].text = "x2"
		await get_tree().create_timer(1).timeout
	
	# Total points on last line
	lines[lines.size()-1][0].text = "Total Points"
	lines[lines.size()-1][1].text = str(total_points)
	
	await get_tree().create_timer(3).timeout
	
	# Hide summary
	yaku_summary.visible = false
	

func animate_glow(glow, from_scale, to_scale):
	glow.visible = true
	var duration = turn_glow_speed * 1000
	var start_time = Time.get_ticks_msec()
	
	while Time.get_ticks_msec() - start_time < duration:
		glow.scale = lerp(from_scale, to_scale, (Time.get_ticks_msec() - start_time) / duration)
		await get_tree().process_frame
		
	glow.scale = to_scale
	

func animate_image(image, from_pos, to_pos):
	image.visible = true
	var duration = 0.5 * 1000
	var start_time = Time.get_ticks_msec()
	
	while Time.get_ticks_msec() - start_time < duration:
		image.global_position = lerp(from_pos, to_pos, (Time.get_ticks_msec() - start_time) / duration)
		await get_tree().process_frame
		
	image.global_position = to_pos

func queue_free_children(parent):
	for child in parent.get_children():
		child.queue_free()
	

func update_table():
	# Make sure we can't select cards on field
	disable_hand(field)
	
	if current_player == 0:
		enable_hand(player_hand)
		disable_hand(enemy_hand)
	else:
		enable_hand(enemy_hand)
		disable_hand(player_hand)
		
	update_glow()
	

func enable_hand(hand):
	for card in hand.get_children():
		# Enable all cards
		card.get_node("button").disabled = false
		
		# Find and highlight cards with matches on field
		find_matches(card)
		if card.matches.size() > 0:
			card.highlight(true)
		else:
			card.highlight(false)
	

func disable_card(card):
	card.get_node("button").disabled = true
	card.highlight(false)
	

func disable_hand(hand):
	for card in hand.get_children():
		disable_card(card)
	

func find_matches(card):
	var matches = []
	for c in field.get_children():
		#print("Checking match: " + card_to_string(card) + " and " + card_to_string(c))
		if c.suite == card.suite:
			#print("Match!")
			matches.append(c)
	card.matches = matches
	

func card_select(card):
	# Selecting a field card out of multiple choices
	if awaiting_input:
		highlight_matches(selected_card, false)
		await match_cards(selected_card, card)
		awaiting_input = false
		return
	
	print("Select: " + card_to_string(card))
	var hand = player_hand
	
	if current_player == 1:
		hand = enemy_hand
	
	# Disable hand to prevent further card selection
	disable_hand(hand)
	
	# Field
	if card.matches.size() == 0:
		await move_card(card, field)
	
	# Match
	elif card.matches.size() == 1:
		await match_cards(card, card.matches[0])
		card.matches[0].highlight(false)
	
	# More than one option
	else:
		await prepare_multiple_matches(card)
	
	# Add card from deck to field
	await from_deck_to_field()
	
	# Check yaku
	var yaku = evaluate_all_yaku()
	
	if yaku.size() > 0:
		var points = 0
		for y in yaku:
			await animate_yaku(y[0], y[1])
			print(y[0])
			points += y[1]
		
		# Double points if 7 or higher
		if points >= 7:
			points *= 2
		
		await show_summary(yaku)
		
		if current_player == 0:
			player_points += points
			update_points(player_points_label, player_points)
		else:
			enemy_points += points
			update_points(enemy_points_label, enemy_points)
		
		end_round()
	else:
		end_turn()
	

func prepare_multiple_matches(card):
	selected_card = card
	# Enable only possible cards on field
	for c in field.get_children():
		if c in card.matches:
			c.get_node("button").disabled = false
			c.highlight(true)
		else:
			c.get_node("button").disabled = true
			c.highlight(false)
	
	awaiting_input = true
	
	# Keep waiting for input (awaiting_input will become false due to next select_card)
	while awaiting_input:
		if current_player == 1:
			await card_select(cpu_select(card.matches, enemy_chaffs, enemy_ribbons, enemy_animals, enemy_brights))
			return
		await get_tree().process_frame

func move_card(card_object, new_parent):
	var old_parent = card_object.get_parent()
	var old_pos = card_object.global_position
	
	if old_parent:
		old_parent.remove_child(card_object)
	
	control.add_child(card_object)
	card_object.global_position = old_pos
	
	var from = card_object.global_position
	var to = new_parent.global_position + Vector2(card_object.size.x * new_parent.scale.x, 0) * new_parent.get_child_count()
	
	if old_parent:
		await animate_card(card_object, from, to, old_parent.scale, new_parent.scale)
	else:
		await animate_card(card_object, from, to, deck_parent.scale, new_parent.scale)
	
	control.remove_child(card_object)
	new_parent.add_child(card_object)
	

func from_deck_to_field():
	var card_object = create_card_object(draw_card())
	print("From deck to field: " + card_to_string(card_object))
	
	find_matches(card_object)
	
	if card_object.matches.size() == 0:
		await move_card(card_object, field)
	
	elif card_object.matches.size() == 1:
		await match_cards(card_object, card_object.matches[0])
	
	else:
		await prepare_multiple_matches(card_object)

func card_press_up(card):
	# Only remove highlight if we are not waiting for multiple choice selection
	if not awaiting_input:
		highlight_matches(card, false)
	

func card_press_down(card):
	highlight_matches(card, true)
	

func highlight_matches(card, state):
	for c in card.matches:
		c.highlight(state)
	

func animate_card(card, from, to, from_scale, to_scale):
	#print("FROM: " + str(from_scale) + " TO: " + str(to_scale))
	var start = Time.get_ticks_msec()
	var duration = animation_speed * 1000
	while(Time.get_ticks_msec() - start <= duration):
		var t = (Time.get_ticks_msec() - start) / duration
		card.global_position = lerp(from, to, t)
		card.scale = lerp(from_scale, to_scale, t)
		await get_tree().process_frame
		
	card.global_position = to
	card.scale = to_scale
	

func animate_yaku(name, points):
	if name == "Sakura Viewing Sake":
		show_sakura_glow()
	elif name == "Moon Viewing Sake":
		show_moon_glow()
	elif name == "Rainy Four Bright":
		show_rain()
		
	yaku_name.text = str(name)
	yaku_points.text = "+" + str(points) + " points"
	
	# Change color scheme
	if yaku_color_schemes.has(name):
		yaku_name.add_theme_color_override("font_color", yaku_color_schemes[name]["color"])
		yaku_name.add_theme_color_override("font_outline_color", yaku_color_schemes[name]["outline_color"])
		
		yaku_points.add_theme_color_override("font_color", yaku_color_schemes[name]["color"])
		yaku_points.add_theme_color_override("font_outline_color", yaku_color_schemes[name]["outline_color"])
	else:
		yaku_name.add_theme_color_override("font_color", yaku_color_schemes["Default"]["color"])
		yaku_name.add_theme_color_override("font_outline_color", yaku_color_schemes["Default"]["outline_color"])
		
		yaku_points.add_theme_color_override("font_color", yaku_color_schemes["Default"]["color"])
		yaku_points.add_theme_color_override("font_outline_color", yaku_color_schemes["Default"]["outline_color"])
	
	yaku_popup.visible = true
	
	await get_tree().create_timer(3).timeout
	yaku_popup.visible = false
	

func get_type(card):
	var tuple = [card.suite, card.number]
	if tuple in brights:
		return TYPE.BRIGHT
	elif tuple in animals:
		return TYPE.ANIMAL
	elif tuple in ribbons:
		return TYPE.RIBBON
	return TYPE.CHAFF
	

func get_matches_parent(card):
	var type = get_type(card)
	if current_player == 0:
		if type == TYPE.BRIGHT:
			return player_brights
		elif type == TYPE.ANIMAL:
			return player_animals
		elif type == TYPE.RIBBON:
			return player_ribbons
		return player_chaffs
	else:
		if type == TYPE.BRIGHT:
			return enemy_brights
		elif type == TYPE.ANIMAL:
			return enemy_animals
		elif type == TYPE.RIBBON:
			return enemy_ribbons
		return enemy_chaffs
	

func match_cards(card1, card2):
	print("Matching: " + card_to_string(card1) + " and "  + card_to_string(card2))
	var parent1 = card1.get_parent()
	var parent2 = card2.get_parent()
	
	var pos1 = card1.global_position
	var pos2 = card2.global_position
	
	if parent1:
		parent1.remove_child(card1)
	
	if parent2:
		parent2.remove_child(card2)
	
	# Reposition in a neutral context
	control.add_child(card1)
	control.add_child(card2)
	
	card1.scale = parent1.scale
	card2.scale = parent2.scale
	
	card1.global_position = pos1
	card2.global_position = pos2
	
	var matches_1 = get_matches_parent(card1)
	var matches_2 = get_matches_parent(card2)
	
	# Move card1 to card2
	card1.set_top_level(true)
	var from = card1.global_position
	var to = card2.global_position + Vector2(25, 25)
	await animate_card(card1, from, to, parent1.scale, parent2.scale)
	
	# Pause
	await get_tree().create_timer(0.5).timeout
	
	# Move both cards from field to match
	from = card1.global_position
	to = matches_1.global_position + Vector2(card1.size.x * 0.5, 0) * matches_1.get_child_count()
	animate_card(card1, from, to, parent2.scale, matches_1.get_parent().scale)
	
	from = card2.global_position
	to = matches_2.global_position + Vector2(card2.size.x * 0.5, 0) * matches_2.get_child_count()
	await animate_card(card2, from, to, parent2.scale, matches_2.get_parent().scale)
	
	# Re-Parent
	control.remove_child(card1)
	control.remove_child(card2)
	
	matches_1.add_child(card1)
	matches_2.add_child(card2)
	
	card1.set_top_level(false)
	

func card_to_string(card):
	return SUITE.keys()[card.suite] + " " + str(get_type(card)) + " [" + str(card.number) + "]"

func evaluate_yaku(yaku_set, matches):
	var yaku_name = null
	var yaku_points = 0
	
	for yaku in yaku_set.keys():
		#print ( "Checking yaku: " + str(yaku))
		var cards_count = matches.get_child_count()
		
		# Not enough cards, continue to next yaku
		if yaku_set[yaku]["count"] > cards_count:
			#print ( "Not enough cards: " + str(yaku_set[yaku]["count"]) + " / " + str(cards_count))
			continue
		
		# Includes cards
		if yaku_set[yaku].has("include"):
			var include =  true
			# For every necessary card
			for card in yaku_set[yaku]["include"]:
				var found = false
				# Check all child cards
				for c in matches.get_children():
					# If found, stop searching children
					if [c.suite, c.number] == card:
						found = true
						#print("Found must include card: " + str(c))
						break 
				# If not found in children, stop searching cards
				if found == false:
					include = false
					break;
			
			# Does not include necessary cards, continue to next yaku
			if not include:
				continue
		
		# Excludes
		if yaku_set[yaku].has("exclude"):
			var exclude =  true
			# For every unnecessary card
			for card in yaku_set[yaku]["exclude"]:
				var found = false
				# Check all child cards
				for c in matches.get_children():
					# If found, stop searching children
					if [c.suite, c.number] == card:
						found = true
						break 
				# If not found in children, stop searching cards
				if found == true:
					exclude = false
					break;
			
			# Includes unnecessary cards, continue to next yaku
			if not exclude:
				continue
		
		# Reaching this point means this yaku is the valid one
		# Return yaku name and calculate points
		yaku_name = yaku
		yaku_points = yaku_set[yaku]["points"]
		if yaku_set[yaku].has("extra_points") and yaku_set[yaku]["extra_points"]:
			var extra_cards = cards_count - yaku_set[yaku]["count"]
			yaku_points += extra_cards
			
		return [yaku_name, yaku_points]
	
	# No suitable yaku was found
	return null

func evaluate_moon_viewing_sake(brights, animals):
	var found_moon = false
	for child in brights.get_children():
		if child.suite == 7 and child.number == 0:
			found_moon = true
			break
	
	if found_moon == false:
		return null
		
	var found_sake = false
	for child in animals.get_children():
		if child.suite == 8 and child.number == 0:
			found_sake = true
			break
			
	if found_sake == false:
		return null
	return [moon_viewing_sake["name"], moon_viewing_sake["points"]]
	
func evaluate_sakura_viewing_sake(brights, animals):
	var found_sakura = false
	for child in brights.get_children():
		if child.suite == 2 and child.number == 0:
			found_sakura = true
			break
	
	if found_sakura == false:
		return null
		
	var found_sake = false
	for child in animals.get_children():
		if child.suite == 8 and child.number == 0:
			found_sake = true
			break
			
	if found_sake == false:
		return null
	return [sakura_viewing_sake["name"], sakura_viewing_sake["points"]]
	

func evaluate_all_yaku():
	var bright = null
	var animal = null
	var ribbon = null
	var chaff = null
	var moon_viewing = null
	var sakura_viewing = null
	
	if current_player == 0:
		bright = evaluate_yaku(bright_yaku, player_brights)
		animal = evaluate_yaku(animal_yaku, player_animals)
		ribbon = evaluate_yaku(ribbon_yaku, player_ribbons)
		chaff = evaluate_yaku(chaff_yaku, player_chaffs)
		moon_viewing = evaluate_moon_viewing_sake(player_brights, player_animals)
		sakura_viewing = evaluate_sakura_viewing_sake(player_brights, player_animals)
		
	else:
		bright = evaluate_yaku(bright_yaku, enemy_brights)
		animal = evaluate_yaku(animal_yaku, enemy_animals)
		ribbon = evaluate_yaku(ribbon_yaku, enemy_ribbons)
		chaff = evaluate_yaku(chaff_yaku, enemy_chaffs)
		moon_viewing = evaluate_moon_viewing_sake(enemy_brights, enemy_animals)
		sakura_viewing = evaluate_sakura_viewing_sake(enemy_brights, enemy_animals)
	
	var yaku = []
	if bright:
		yaku.append(bright)
	if animal:
		yaku.append(animal)
	if ribbon:
		yaku.append(ribbon)
	if chaff:
		yaku.append(chaff)
	if moon_viewing:
		yaku.append(moon_viewing)
	if sakura_viewing:
		yaku.append(sakura_viewing)
	
	return yaku

func cpu_select(cards, chaff_matches, ribbon_matches, animal_matches, bright_matches):
	# Each vector will contain a dictionary with the card and the amount of points 
	var vectors = []
	
	for card in cards:
		var vector = {"card" : card, "points" : 0}
		
		# Card with matches starts at 1
		if card.matches.size() > 0:
			vector["points"] = 1
		
		var type = get_type(card)
		
		if card.suite == 8 and card.number == 0: # Sake
			vector["points"] *= 8
		elif type == TYPE.BRIGHT:
			vector["points"] *= 4
			vector["points"] += bright_matches.get_child_count()
		elif type == TYPE.RIBBON:
			vector["points"] *= 2
			vector["points"] += ribbon_matches.get_child_count()
		elif type == TYPE.ANIMAL:
			vector["points"] *= 2
			vector["points"] += animal_matches.get_child_count()
		else:
			vector["points"] += chaff_matches.get_child_count()
			
		vectors.append(vector)
	
	var highest_points = -1
	var highest_card = null
	
	for vector in vectors:
		if vector["points"] > highest_points:
			highest_points = vector["points"]
			highest_card = vector["card"]
	
	return highest_card
	
