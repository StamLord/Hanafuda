extends GPUParticles2D

var extra_particles = []

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			global_position = event.global_position
			emit_particle(global_transform, Vector2.ZERO, Color.WHITE, Color.WHITE, 0)
	
