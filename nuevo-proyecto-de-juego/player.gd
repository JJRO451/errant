extends CharacterBody2D

var speed := 300.0

func _physics_process(_delta):
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	move_and_slide()

	var screen_size = get_viewport_rect().size

	global_position.x = clamp(
		global_position.x,
		64.0,
		screen_size.x - 64.0
	)

	global_position.y = clamp(
		global_position.y,
		64.0,
		screen_size.y - 64.0
	)
