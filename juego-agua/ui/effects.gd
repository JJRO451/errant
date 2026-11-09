class_name Effects
extends RefCounted
## Utilidades para efectos visuales sencillos. Se usan sin crear objetos:
##   Effects.burst(get_parent(), global_position, Color.YELLOW)


## Crea una explosión de partículas de un solo uso dentro de "parent",
## en la posición global "pos". Se borra sola al terminar.
static func burst(
	parent: Node,
	pos: Vector2,
	color: Color,
	amount: int = 14,
	speed: float = 140.0,
	lifetime: float = 0.5
) -> void:
	if parent == null or not parent.is_inside_tree():
		return

	var particles := CPUParticles2D.new()
	# Que las partículas sigan moviéndose aunque el juego esté en pausa
	# (por ejemplo, la explosión de la última moneda tras ganar).
	particles.process_mode = Node.PROCESS_MODE_ALWAYS
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = amount
	particles.lifetime = lifetime
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = speed * 0.5
	particles.initial_velocity_max = speed
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = color

	# Se desvanecen hacia el final de su vida.
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 1))
	fade.set_color(1, Color(1, 1, 1, 0))
	particles.color_ramp = fade

	parent.add_child(particles)
	particles.global_position = pos
	particles.emitting = true

	# El temporizador también debe correr durante la pausa.
	parent.get_tree().create_timer(lifetime + 0.2, true).timeout.connect(particles.queue_free)
