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

const four_of_a_kind = {
	"name" : "Four of a Kind",
	"points" : 6
}

const four_pairs = {
	"name" : "Four Pairs",
	"points" : 6
}

# Configurable
@export var animation_speed = 0.2
@export var turn_glow_speed = 0.2
@export var yaku_glow_duration = 4

@export var yaku_color_schemes = {
	"Default" : {"color" : "ffffff", "outline_color" : "000000"},
	"Moon Viewing Sake" : {"color" : "fbfbfb", "outline_color" : "2c3749"},
	"Sakura Viewing Sake" : {"color" : "feafd0", "outline_color" : "be3749"},
	"Poetry Ribbons" : {"color" : "ff1b00", "outline_color" : "ffffff"},
	"Blue Ribbons" : {"color" : "1a56ff", "outline_color" : "ffffff"},
	"Ribbons" : {"color" : "ff1b00", "outline_color" : "000000"}
}

@export var show_enemy_hand = false

# References
var card_visual_path = preload("res://scenes/card_visual.tscn")

@onready var player_glow = %player_glow
@onready var enemy_glow = %enemy_glow
@onready var sakura_glow = %sakura_glow
@onready var moon_glow = %moon_glow
@onready var moon_sprite = %moon_sprite
@onready var three_brights_glow = %three_brights_glow
@onready var rainy_four_brights_glow = %rainy_four_brights_glow
@onready var four_brights_glow = %four_brights_glow
@onready var five_brights_glow = %five_brights_glow

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

@onready var koikoi_selection = %koikoi_selection
@onready var koikoi_popup = %koikoi_popup
@onready var finish_popup = %finish_popup
@onready var draw_popup = %draw_popup

@onready var yaku_summary = %yaku_summary
@onready var yaku_summary_container = %yaku_summary/v_container

@onready var win_screen = %win_screen
@onready var win_text = %win_screen/win_text

@onready var audio_players = $"../camera/audio_players"

@onready var draw_sounds = [
	preload("res://assets/audio/cardSlide4.wav"), 
	preload("res://assets/audio/cardSlide5.wav"), 
	preload("res://assets/audio/cardSlide6.wav"),
	preload("res://assets/audio/cardSlide7.wav")]

@onready var place_sounds = [
	preload("res://assets/audio/cardPlace1.wav"), 
	preload("res://assets/audio/cardPlace2.wav"), 
	preload("res://assets/audio/cardPlace3.wav"),
	preload("res://assets/audio/cardPlace4.wav")]

@onready var match_sounds = [
	preload("res://assets/audio/cardShove1.wav")]
	
# Game Variables
var round = 0
var max_round = 3
var current_player = 0

var player_points = 0
var enemy_points = 0

var deck : Array

var awaiting_input = false
var selected_card = null

signal koikoi_signal(state)
var player_koikoi = false
var player_koikoi_points = 0

var enemy_koikoi = false
var enemy_koikoi_points = 0

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
#	await add_card({"suite" : 0, "number" : 0}, field) # Sun
#	await add_card({"suite" : 10, "number" : 0}, field) # Rainy
#	await add_card({"suite" : 11, "number" : 0}, field) # Phoenix
#	await add_card({"suite" : 2, "number" : 1}, player_hand) # Sakura match
#	await add_card({"suite" : 8, "number" : 1}, player_hand) # Sake match
#	await add_card({"suite" : 7, "number" : 1}, player_hand) # Moon match
#	await add_card({"suite" : 0, "number" : 1}, player_hand) # Sun match
#	await add_card({"suite" : 10, "number" : 1}, player_hand) # Rainy Match
#	await add_card({"suite" : 11, "number" : 1}, player_hand) # Phoenix Match
	
	# Four of a Kind (Player)
#	await add_card({"suite" : 10, "number" : 0}, player_hand)
#	await add_card({"suite" : 10, "number" : 1}, player_hand) 
#	await add_card({"suite" : 10, "number" : 2}, player_hand)
#	await add_card({"suite" : 10, "number" : 3}, player_hand)

	# Four of a Kind (Enemy)
#	await add_card({"suite" : 10, "number" : 0}, enemy_hand)
#	await add_card({"suite" : 10, "number" : 1}, enemy_hand) 
#	await add_card({"suite" : 10, "number" : 2}, enemy_hand)
#	await add_card({"suite" : 10, "number" : 3}, enemy_hand)
	
	# Four of a Kind (Field)
#	await add_card({"suite" : 10, "number" : 0}, field)
#	await add_card({"suite" : 10, "number" : 1}, field) 
#	await add_card({"suite" : 10, "number" : 2}, field)
#	await add_card({"suite" : 10, "number" : 3}, field)

	# Four Pairs (Player)
#	await add_card({"suite" : 10, "number" : 0}, player_hand)
#	await add_card({"suite" : 10, "number" : 1}, player_hand)
#	await add_card({"suite" : 0, "number" : 0}, player_hand)
#	await add_card({"suite" : 0, "number" : 1}, player_hand)
#	await add_card({"suite" : 1, "number" : 0}, player_hand)
#	await add_card({"suite" : 1, "number" : 1}, player_hand)
#	await add_card({"suite" : 3, "number" : 0}, player_hand)
#	await add_card({"suite" : 3, "number" : 1}, player_hand)
	
	# Four Pairs (Enemy)
#	await add_card({"suite" : 10, "number" : 0}, enemy_hand)
#	await add_card({"suite" : 10, "number" : 1}, enemy_hand)
#	await add_card({"suite" : 0, "number" : 0}, enemy_hand)
#	await add_card({"suite" : 0, "number" : 1}, enemy_hand)
#	await add_card({"suite" : 1, "number" : 0}, enemy_hand)
#	await add_card({"suite" : 1, "number" : 1}, enemy_hand)
#	await add_card({"suite" : 3, "number" : 0}, enemy_hand)
#	await add_card({"suite" : 3, "number" : 1}, enemy_hand)
	
#	update_table()
#	return
	
	for i in range(4):
		await add_card(draw_card(), enemy_hand, show_enemy_hand)
		await add_card(draw_card(), enemy_hand, show_enemy_hand)

		await add_card(draw_card(), field)
		await add_card(draw_card(), field)

		await add_card(draw_card(), player_hand)
		await add_card(draw_card(), player_hand)
	
	update_table()
	
	# Check if for lucky hands which result in auto win or a re-deal
	
	var player_lucky = evaluate_lucky_hand(player_hand)
	var enemy_lucky = evaluate_lucky_hand(enemy_hand)
	var field_lucky = evaluate_lucky_hand(field)
	
	# We only animate the first result if multiple ( Should be "Four of a Kind" )
	# Both players are lucky - Draw
	if player_lucky.size() > 0 and enemy_lucky.size() > 0:
		var cards = player_lucky[player_lucky.keys()[0]]
		var cards2 = enemy_lucky[enemy_lucky.keys()[0]]
		
		animate_cards_raise(cards, Vector2(0, -50))
		animate_cards_raise(cards2, Vector2(0, 50))
		
		end_round_draw()
		return
	# Player wins
	elif player_lucky.size() > 0:
		# Raise cards relevant to yaku
		var cards = player_lucky[player_lucky.keys()[0]]
		animate_cards_raise(cards, Vector2(0, -50))
		
		# Animate yaku
		var yaku = player_lucky.keys()[0]
		await animate_yaku(yaku["name"], yaku["points"])
		player_points += yaku["points"]
		update_points(player_points_label, player_points)
		end_round()
		return
	# Enemy wins
	elif enemy_lucky.size() > 0:
		# Raise cards relevant to yaku
		var cards = enemy_lucky[enemy_lucky.keys()[0]]
		animate_cards_raise(cards, Vector2(0, 50))
		
		# Animate yaku
		var yaku = enemy_lucky.keys()[0]
		await animate_yaku(yaku["name"], yaku["points"])
		enemy_points += yaku["points"]
		update_points(enemy_points_label, enemy_points)
		end_round()
		return
	# Field got one of the lucky hands - Draw
	elif field_lucky.size() > 0:
		# Raise cards relevant to yaku
		var cards = field_lucky[field_lucky.keys()[0]]
		animate_cards_raise(cards, Vector2(0, -50))
		
		# Animate yaku
		await animate_yaku("Re-Deal", 0)
		end_round_draw()
		return
		
	if current_player == 1:
		cpu_turn()
	

func draw_card():
	var card = deck.pop_front()
	play_sound(draw_sounds.pick_random())
	return card
	

func create_card_object(card, face_up = true):
	var card_object = card_visual_path.instantiate()
	deck_parent.add_child(card_object)
	
	var button = card_object.get_node("button")
	button.disabled = true
	button.pressed.connect(card_select.bind(card_object))
	button.button_down.connect(card_press_down.bind(card_object))
	button.button_up.connect(card_press_up.bind(card_object))
	button.tooltip_text = card_to_string(card)
	
	card_object.set_card(card)
	card_object.set_face_up(face_up)
	
	return card_object
	

func add_card(card, hand, face_up = true):
	var card_object = create_card_object(card, face_up)
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
	
	# No more cards on field, both hands are empty or deck is empty
	if field.get_child_count() < 1 or player_hand.get_child_count() < 1 and enemy_hand.get_child_count() < 1 or deck.size() < 1:
		end_round_draw()
		return
	
	# Next player's hand
	var hand = player_hand
	if current_player == 1:
		hand = enemy_hand
	
	# If next player has no cards, pass turn
	if hand.get_child_count() < 1:
		current_player += 1
		current_player %= 2
	
	update_table()
		
	if current_player == 1:
		cpu_turn()
	

func end_round_draw():
	print("DRAW")
	draw_popup.visible = true
	await get_tree().create_timer(3).timeout
	draw_popup.visible = false
	end_round()

func end_round():
	# Stop turn glow
	stop_turn_glow()
	
	round += 1
	
	# Reset koikoi flags
	player_koikoi = false
	enemy_koikoi = false
	
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
	stop_turn_glow()
	
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
	

func sort_suites(hand):
	var suites = {}
	for card in hand.get_children():
		if not suites.has(card.suite):
			suites[card.suite] = []
		suites[card.suite].append(card)
		
	return suites
	

func evaluate_lucky_hand(hand):
	# Pairs of yaku(dict) : [card, card, card..]
	var result = {}
	
	# Sort cards into dictionary of {suite: [card, card2, ..]}
	var suites = sort_suites(hand)
	
	# Check for 4 of cards of the same suite
	# and check for 4 pairs of same suite
	var pairs = 0
	var pair_cards = []
	for key in suites.keys():
		if suites[key].size() >= 2:
			pairs += 1
			pair_cards.append_array(suites[key])
		if suites[key].size() >= 4:
			result[four_of_a_kind] = suites[key]
	
	if pairs >= 4:
		result[four_pairs] = pair_cards
	
	return result
	

func update_glow():
	if current_player == 0:
		animate_glow(player_glow, Vector2(1,0), Vector2(1,1))
		enemy_glow.visible = false
	else:
		animate_glow(enemy_glow, Vector2(1,0), Vector2(1,1))
		player_glow.visible = false
	

func stop_turn_glow():
	if current_player == 0 and player_glow.scale.y > 0:
		animate_glow(player_glow, Vector2(1,1), Vector2(1,0))
	elif enemy_glow.scale.y > 0:
		animate_glow(enemy_glow, Vector2(1,1), Vector2(1,0))
	
func show_sakura_glow():
	sakura_particles.emitting = true
	await animate_glow(sakura_glow, Vector2(2,2), Vector2(1,1), 1.0)
	await get_tree().create_timer(yaku_glow_duration - 2).timeout
	await animate_glow(sakura_glow, Vector2(1,1), Vector2(2,2), 1.0)
	sakura_particles.emitting = false
	sakura_glow.visible = false
	
func show_moon_glow():
	# Move in
	animate_glow(moon_glow, Vector2(1,0), Vector2(1,1))
	await animate_image(moon_sprite, moon_sprite.global_position - Vector2(0, 600), moon_sprite.global_position)
	
	# Wait
	await get_tree().create_timer(3).timeout
	
	# Move out
	await animate_image(moon_sprite, moon_sprite.global_position, moon_sprite.global_position - Vector2(0, 600))
	await animate_glow(moon_glow, Vector2(1,1), Vector2(1,0))
	
	moon_glow.visible = false
	moon_sprite.visible = false
	
	# Reset position
	moon_sprite.global_position += Vector2(0, 600)

func show_rain():
	rain_particles.emitting = true
	await get_tree().create_timer(3).timeout
	rain_particles.emitting = false
	

func show_three_brights_glow():
	await animate_glow(three_brights_glow, Vector2(1,0), Vector2(1,1))
	await get_tree().create_timer(yaku_glow_duration).timeout
	await animate_glow(three_brights_glow, Vector2(1,1), Vector2(1,0))
	three_brights_glow.visible = false
	

func show_rainy_four_brights_glow():
	await animate_glow(rainy_four_brights_glow, Vector2(1,0), Vector2(1,1))
	await get_tree().create_timer(yaku_glow_duration).timeout
	await animate_glow(rainy_four_brights_glow, Vector2(1,1), Vector2(1,0))
	rainy_four_brights_glow.visible = false
	

func show_four_brights_glow():
	await animate_glow(four_brights_glow, Vector2(2,2), Vector2(1,1), 1.0)
	await get_tree().create_timer(yaku_glow_duration - 2).timeout
	await animate_glow(four_brights_glow, Vector2(1,1), Vector2(2,2), 1.0)
	four_brights_glow.visible = false
	

func show_five_brights_glow():
	await animate_glow(five_brights_glow, Vector2(4,4), Vector2(1,1), 1.0)
	await get_tree().create_timer(yaku_glow_duration - 2).timeout
	await animate_glow(five_brights_glow, Vector2(1,1), Vector2(4,4), 1.0)
	five_brights_glow.visible = false
	

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
	# Over 7
	if total_points >= 7:
		total_points *= 2
		lines[lines.size()-3][0].text = "Over 7"
		lines[lines.size()-3][1].text = "x2"
		await get_tree().create_timer(1).timeout
	
	# Opposite player koikoi
	if current_player == 0 and enemy_koikoi or current_player == 1 and player_koikoi:
		total_points *= 2
		lines[lines.size()-2][0].text = "Koi-Koi"
		lines[lines.size()-2][1].text = "x2"
		await get_tree().create_timer(1).timeout
	
	# Total points on last line
	lines[lines.size()-1][0].text = "Total Points"
	lines[lines.size()-1][1].text = str(total_points)
	
	await get_tree().create_timer(3).timeout
	
	# Hide summary
	yaku_summary.visible = false
	

func show_koikoi_selection():
	koikoi_selection.visible = true
	
	# Wait for either koikoi or finish
	var is_koikoi = await koikoi_signal
	
	koikoi_selection.visible = false
	
	# Show relevant popup
	await show_koikoi_popup(is_koikoi)
	
	return is_koikoi
	

func show_koikoi_popup(is_koikoi):
	var popup = finish_popup
	if is_koikoi:
		popup = koikoi_popup
	
	popup.visible = true
	await get_tree().create_timer(3).timeout
	popup.visible = false
	

func animate_glow(glow, from_scale, to_scale, duration = turn_glow_speed):
	glow.visible = true
	duration *= 1000
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
	
	# Flip card up if face down
	if not card.face_up:
		await card.flip_up()
	
	# Field
	if card.matches.size() == 0:
		# Sound
		play_sound(place_sounds.pick_random())
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
		var base_points = evaluate_base_points(yaku)
		var points = base_points
		
		# If we are in koikoi, we need to make sure we have a better hand 
		# than previous. Otherwise, turn ends normally without any yaku
		if current_player == 0 and player_koikoi and base_points <= player_koikoi_points:
			print("Prev points: " + str(player_koikoi_points) + " New points: " + str(base_points))
			end_turn()
			return
		elif current_player == 1 and enemy_koikoi and base_points <= enemy_koikoi_points:
			print("Prev points: " + str(enemy_koikoi_points) + " New points: " + str(base_points))
			end_turn()
			return
		
		for y in yaku:
			await animate_yaku(y[0], y[1])
			print(y[0])
		
		# Double points if 7 or higher
		if points >= 7:
			points *= 2
		
		# Opposite player koikoi
		if current_player == 0 and enemy_koikoi or current_player == 1 and player_koikoi:
			points *= 2
		
		# Wait for choice to continue (koikoi) or finish round
		var is_koikoi = false
		
		if current_player == 0:
			is_koikoi = await show_koikoi_selection()
			if is_koikoi:
				player_koikoi_points = base_points # Track this hand's points to compare next one
		else:
			is_koikoi = await cpu_select_koikoi()
			if is_koikoi:
				enemy_koikoi_points = base_points
		
		# End turn and conitnue playing
		if is_koikoi:
			end_turn()
			return
		
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
	print("Moving " + card_to_string(card_object) + " to " + str(new_parent))
	var old_parent = card_object.get_parent()
	var old_pos = card_object.global_position
	
	if old_parent:
		old_parent.remove_child(card_object)
	
	control.add_child(card_object)
	card_object.global_position = old_pos
	
	var from = card_object.global_position
	var width = card_object.size.x * new_parent.scale.x
	var to = new_parent.global_position + Vector2(width * new_parent.get_child_count(), 0)
	
	if old_parent:
		await animate_card(card_object, from, to, old_parent.scale, new_parent.scale)
	else:
		await animate_card(card_object, from, to, deck_parent.scale, new_parent.scale)
	
	control.remove_child(card_object)
	new_parent.add_child(card_object)
	
	# For some reason if we don't wait a frame, 
	# the card position is not updated in time and it causes an issue 
	# when match_card is being called in from_deck_to_field where the new card
	# moves to the previous card's position in the hand instead of field
	await get_tree().process_frame
	

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
	

func animate_card_raise(card, offset):
	var from = card.global_position
	var to = from + offset
	await animate_card(card, from, to, card.scale, card.scale)
	

func animate_cards_raise(cards, offset):
	for i in range(cards.size()):
		animate_card_raise(cards[i], offset)
	

func animate_yaku(name, points):
	# Stop turn glow
	stop_turn_glow()
	
	# Animate yaku
	if name == "Sakura Viewing Sake":
		show_sakura_glow()
	elif name == "Moon Viewing Sake":
		show_moon_glow()
	elif name == "Three Bright":
		show_three_brights_glow()
	elif name == "Rainy Four Bright":
		show_rain()
		show_rainy_four_brights_glow()
	elif name == "Four Bright":
		show_four_brights_glow()
	elif name == "Five Bright":
		show_five_brights_glow()
		
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
	
	await get_tree().create_timer(yaku_glow_duration).timeout
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
	
	# Get parents
	var parent1 = card1.get_parent()
	var parent2 = card2.get_parent()
	
	# Reposition card1 in a neutral context
	var pos1 = card1.global_position
	
	if parent1:
		parent1.remove_child(card1)
	
	control.add_child(card1)	
	
	card1.scale = parent1.scale
	card1.global_position = pos1
	
	# Get the match parent (bright, animals, etc.)
	var matches_1 = get_matches_parent(card1)
	var matches_2 = get_matches_parent(card2)
	
	# Sound
	play_sound(place_sounds.pick_random())
	
	# Move card1 to card2
	card1.set_top_level(true)
	var from = card1.global_position
	var to = card2.global_position + Vector2(25, 25)
	await animate_card(card1, from, to, parent1.scale, parent2.scale)
	
	# Pause
	await get_tree().create_timer(0.5).timeout
	
	# We move card2 from the field to a netural context,
	# only after moving card1 to avoid premature hbox update
	var pos2 = card2.global_position
	
	if parent2:
		parent2.remove_child(card2)
	
	control.add_child(card2)
	
	card2.scale = parent2.scale
	card2.global_position = pos2
	
	# Sound
	play_sound(match_sounds.pick_random())
	
	# Move both cards from field to match
	from = card1.global_position
	to = matches_1.global_position + Vector2(card1.size.x * 0.5, 0) * matches_1.get_child_count()
	# Use parent2 scale as origin for both cards
	animate_card(card1, from, to, parent2.scale, matches_1.get_parent().get_parent().scale)
	
	from = card2.global_position
	to = matches_2.global_position + Vector2(card2.size.x * 0.5, 0) * matches_2.get_child_count()
	await animate_card(card2, from, to, parent2.scale, matches_2.get_parent().get_parent().scale)
	
	# Re-Parent
	control.remove_child(card1)
	control.remove_child(card2)
	
	matches_1.add_child(card1)
	matches_2.add_child(card2)
	
	card1.set_top_level(false)
	

func card_to_string(card):
	return SUITE.keys()[card.suite] + " " + str(TYPE.keys()[get_type(card)])

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
	

func evaluate_base_points(all_yaku):
	var points = 0
	for yaku in all_yaku:
		points += yaku[1]
	
	return points
	

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
	

func _on_koikoi_pressed():
	if current_player == 0:
		player_koikoi = true
	else:
		enemy_koikoi = true
	
	koikoi_signal.emit(true)
	

func _on_finish_pressed():
	koikoi_signal.emit(false)
	

func cpu_select_koikoi():
	# Pretend to think
	await get_tree().create_timer(1).timeout
	
	# For now, always choose to finish
	var is_koikoi = false
	
	if is_koikoi:
		_on_koikoi_pressed()
	else:
		_on_finish_pressed()
	
	await show_koikoi_popup(is_koikoi)

func play_sound(sound):
	for player in audio_players.get_children():
		if not player.playing:
			print(player)
			player.stream = sound
			player.play()
			return
	
