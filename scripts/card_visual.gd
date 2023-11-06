extends TextureRect

@onready var highlight_border = $highlight

var suite : int
var number : int
var face_up : bool
var matches = []

func set_card(card):
	suite = card.suite
	number = card.number
	update_texture()
	

func update_texture():
	texture.region = Rect2(118 * number, 192 * suite, 118, 192)
	
func highlight(state : bool):
	highlight_border.visible = state

func set_top_level(state : bool):
	top_level = state
