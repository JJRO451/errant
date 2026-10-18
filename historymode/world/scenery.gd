class_name Scenery
extends Node2D
## El pueblo: pasto, caminos, plaza con fuente, estanque, casas y árboles.
## Todo se dibuja con código (no necesita imágenes) y las casas, los árboles,
## la fuente y el estanque bloquean el paso al jugador.
## Para cambiar el tamaño del mundo, edita WORLD_SIZE.

const WORLD_SIZE := Vector2(3000, 1700)

const GRASS := Color(0.47, 0.73, 0.42)
const GRASS_DARK := Color(0.4, 0.66, 0.36)
const PATH_COLOR := Color(0.86, 0.77, 0.59)
const WATER := Color(0.33, 0.6, 0.85)
const PLAZA_CENTER := Vector2(1500, 850)

const HOUSE_SIZE := Vector2(200, 130)
const ROOF_HEIGHT := 70.0
## Esquina superior izquierda del muro de cada casa y color de la pared.
const HOUSES := [
	[Vector2(400, 600), Color(0.95, 0.82, 0.62)],
	[Vector2(950, 590), Color(0.82, 0.9, 0.95)],
	[Vector2(1950, 600), Color(0.95, 0.85, 0.85)],
	[Vector2(2450, 590), Color(0.88, 0.95, 0.8)],
]

const POND_CENTER := Vector2(700, 1320)
const POND_RADIUS := Vector2(260, 140)

## Posición de cada árbol (el punto es el centro de la copa).
const TREES := [
	Vector2(250, 250), Vector2(700, 200), Vector2(1200, 320), Vector2(1750, 250),
	Vector2(2250, 200), Vector2(2750, 300), Vector2(2850, 650), Vector2(150, 700),
	Vector2(250, 1000), Vector2(200, 1450), Vector2(1200, 1550), Vector2(1300, 1100),
	Vector2(1750, 1100), Vector2(2000, 1350), Vector2(2350, 1150), Vector2(2700, 1500),
	Vector2(2900, 1200), Vector2(600, 1600),
]


func _ready() -> void:
	for house in HOUSES:
		var pos: Vector2 = house[0]
		_add_block(Rect2(
			pos.x - 15.0,
			pos.y - ROOF_HEIGHT,
			HOUSE_SIZE.x + 30.0,
			HOUSE_SIZE.y + ROOF_HEIGHT
		))

	for t in TREES:
		var tree: Vector2 = t
		# Solo bloquea el tronco, para poder pasar por debajo de la copa.
		_add_block(Rect2(tree.x - 12.0, tree.y + 34.0, 24.0, 16.0))

	# Estanque y fuente.
	_add_block(Rect2(
		POND_CENTER - Vector2(POND_RADIUS.x * 0.8, POND_RADIUS.y * 0.7),
		Vector2(POND_RADIUS.x * 1.6, POND_RADIUS.y * 1.4)
	))
	_add_block(Rect2(PLAZA_CENTER - Vector2(48, 48), Vector2(96, 96)))


func _draw() -> void:
	_draw_ground()
	_draw_paths()
	_draw_pond()
	_draw_fountain()

	for house in HOUSES:
		_draw_house(house[0], house[1])

	for tree in TREES:
		_draw_tree(tree)

	# Borde del mundo.
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color(0.2, 0.32, 0.2), false, 14.0)


# --- Dibujo -----------------------------------------------------------------

func _draw_ground() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), GRASS)

	# Manchas de pasto y flores en posiciones fijas (la semilla no cambia).
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in 90:
		var p := Vector2(rng.randf_range(0, WORLD_SIZE.x), rng.randf_range(0, WORLD_SIZE.y))
		draw_circle(p, rng.randf_range(25.0, 70.0), GRASS_DARK)

	var flower_colors := [
		Color(1, 1, 1), Color(1, 0.9, 0.3), Color(1, 0.6, 0.75), Color(0.8, 0.7, 1)
	]
	for i in 160:
		var p := Vector2(rng.randf_range(0, WORLD_SIZE.x), rng.randf_range(0, WORLD_SIZE.y))
		draw_circle(p, 4.0, flower_colors[i % flower_colors.size()])


func _draw_paths() -> void:
	# Camino horizontal y vertical, con una plaza redonda en el cruce.
	draw_rect(Rect2(0, 800, WORLD_SIZE.x, 100), PATH_COLOR)
	draw_rect(Rect2(1450, 0, 100, WORLD_SIZE.y), PATH_COLOR)
	draw_circle(PLAZA_CENTER, 170.0, PATH_COLOR.lightened(0.08))
	draw_arc(PLAZA_CENTER, 170.0, 0.0, TAU, 48, PATH_COLOR.darkened(0.15), 4.0)


func _draw_pond() -> void:
	var scale_y := POND_RADIUS.y / POND_RADIUS.x
	draw_set_transform(POND_CENTER, 0.0, Vector2(1.0, scale_y))
	draw_circle(Vector2.ZERO, POND_RADIUS.x + 12.0, Color(0.75, 0.68, 0.5))
	draw_circle(Vector2.ZERO, POND_RADIUS.x, WATER)
	draw_circle(Vector2(-60, -30), POND_RADIUS.x * 0.45, WATER.lightened(0.15))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_fountain() -> void:
	draw_circle(PLAZA_CENTER, 58.0, Color(0.62, 0.62, 0.66))
	draw_circle(PLAZA_CENTER, 46.0, WATER)
	draw_circle(PLAZA_CENTER, 14.0, Color(0.75, 0.88, 1.0))


func _draw_house(pos: Vector2, wall_color: Color) -> void:
	var w := HOUSE_SIZE.x
	var h := HOUSE_SIZE.y

	# Pared.
	draw_rect(Rect2(pos, HOUSE_SIZE), wall_color)
	draw_rect(Rect2(pos, HOUSE_SIZE), wall_color.darkened(0.3), false, 3.0)

	# Techo.
	var roof := PackedVector2Array([
		Vector2(pos.x - 15.0, pos.y),
		Vector2(pos.x + w + 15.0, pos.y),
		Vector2(pos.x + w * 0.5, pos.y - ROOF_HEIGHT),
	])
	draw_colored_polygon(roof, Color(0.72, 0.3, 0.25))

	# Puerta y ventanas.
	draw_rect(Rect2(pos.x + w * 0.5 - 18.0, pos.y + h - 58.0, 36.0, 58.0), Color(0.45, 0.28, 0.15))
	draw_rect(Rect2(pos.x + 25.0, pos.y + 30.0, 40.0, 40.0), Color(0.7, 0.88, 1.0))
	draw_rect(Rect2(pos.x + w - 65.0, pos.y + 30.0, 40.0, 40.0), Color(0.7, 0.88, 1.0))


func _draw_tree(pos: Vector2) -> void:
	# Sombra, tronco y copa hecha con tres círculos.
	draw_set_transform(pos + Vector2(0, 50), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 50.0, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_rect(Rect2(pos.x - 10.0, pos.y + 10.0, 20.0, 42.0), Color(0.45, 0.3, 0.17))
	draw_circle(pos + Vector2(-30, 8), 38.0, Color(0.25, 0.55, 0.28))
	draw_circle(pos + Vector2(30, 8), 38.0, Color(0.25, 0.55, 0.28))
	draw_circle(pos + Vector2(0, -10), 52.0, Color(0.3, 0.62, 0.32))


# --- Colisiones -------------------------------------------------------------

func _add_block(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.position = rect.get_center()
	body.add_child(shape)
	add_child(body)
