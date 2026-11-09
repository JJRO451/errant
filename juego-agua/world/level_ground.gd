@tool
class_name LevelGround
extends Node2D
## Suelo de un escenario: color, manchas, puntitos (flores, polvo, luciérnagas)
## y una cuadrícula opcional (losas de piedra). Se ve directamente en el editor.
## El tamaño del mundo que escribas aquí lo usan la cámara y los límites del jugador.

@export var world_size: Vector2 = Vector2(3000, 1700):
	set(value):
		world_size = value
		queue_redraw()

@export_group("Colores")
@export var ground_color: Color = Color(0.47, 0.73, 0.42):
	set(value):
		ground_color = value
		queue_redraw()
@export var patch_color: Color = Color(0.4, 0.66, 0.36):
	set(value):
		patch_color = value
		queue_redraw()
@export var border_color: Color = Color(0.2, 0.32, 0.2):
	set(value):
		border_color = value
		queue_redraw()

@export_group("Detalles")
## Manchas grandes de otro tono sobre el suelo.
@export_range(0, 400) var patch_count: int = 40:
	set(value):
		patch_count = value
		queue_redraw()
## Puntitos de adorno (flores, polvo, luciérnagas...) y sus colores.
@export_range(0, 3000) var speckle_count: int = 120:
	set(value):
		speckle_count = value
		queue_redraw()
@export var speckle_colors: PackedColorArray = PackedColorArray([Color(1, 1, 1, 0.8)]):
	set(value):
		speckle_colors = value
		queue_redraw()
## Cambia este número para obtener otra distribución de manchas y puntitos.
@export var random_seed: int = 1:
	set(value):
		random_seed = value
		queue_redraw()

@export_group("Losas")
## Tamaño de las losas en píxeles (0 = sin cuadrícula).
@export_range(0.0, 400.0, 8.0) var tile_size: float = 0.0:
	set(value):
		tile_size = value
		queue_redraw()
@export var tile_line_color: Color = Color(0, 0, 0, 0.15):
	set(value):
		tile_line_color = value
		queue_redraw()


func _init() -> void:
	# Siempre por debajo de todo lo demás.
	z_index = -10


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size), ground_color)

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	for i in patch_count:
		var center := Vector2(rng.randf_range(0.0, world_size.x), rng.randf_range(0.0, world_size.y))
		draw_circle(center, rng.randf_range(50.0, 170.0), patch_color)

	if tile_size >= 8.0:
		var x := tile_size
		while x < world_size.x:
			draw_line(Vector2(x, 0), Vector2(x, world_size.y), tile_line_color, 2.0)
			x += tile_size
		var y := tile_size
		while y < world_size.y:
			draw_line(Vector2(0, y), Vector2(world_size.x, y), tile_line_color, 2.0)
			y += tile_size

	if not speckle_colors.is_empty():
		for i in speckle_count:
			var p := Vector2(rng.randf_range(10.0, world_size.x - 10.0), rng.randf_range(10.0, world_size.y - 10.0))
			var c := speckle_colors[rng.randi() % speckle_colors.size()]
			draw_circle(p, rng.randf_range(2.0, 4.5), c)

	draw_rect(Rect2(Vector2.ZERO, world_size), border_color, false, 14.0)
