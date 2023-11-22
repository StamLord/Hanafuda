extends TextureRect

@onready var highlight_border = $highlight
@onready var backface = $backface

var suite : int
var number : int
var face_up : bool
var matches = []

func set_card(card):
	suite = card.suite
	number = card.number
	update_texture()
	

func update_texture():
	texture.region = Rect2(117 * number, 192 * suite, 117, 192)
	
func highlight(state : bool):
	highlight_border.visible = state

func set_face_up(state):
	if state:
		face_up = true
		backface.visible = false
	else:
		face_up = false
		backface.visible = true
		

func set_top_level(state : bool):
	top_level = state

func flip_up():
	await animate_scale_x(1, 0, 0.2)
	set_face_up(true)
	await animate_scale_x(0, 1, 0.2)
	

func flip_down():
	await animate_scale_x(1, 0, 0.2)
	set_face_up(false)
	await animate_scale_x(0, 1, 0.2)
	

func animate_scale_x(from, to, duration):
	var startTime = Time.get_ticks_msec()
	var totalTime = duration * 1000 # msec
	
	while Time.get_ticks_msec() - startTime <= totalTime:
		var t = (Time.get_ticks_msec() - startTime) / totalTime
		scale.x = lerp(from, to, t)
		await get_tree().process_frame
	scale.x = to
	
