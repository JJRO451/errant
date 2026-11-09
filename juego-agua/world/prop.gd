@tool
class_name Prop
extends StaticBody2D
## Objeto de decorado que se ve en el editor: árbol, roca, muro, pilar, antorcha...
## Arrastra world/prop.tscn al escenario, elige el "Kind" (tipo) en el Inspector
## y duplícalo con Ctrl+D. Todo se personaliza ahí mismo:
##   kind         - qué objeto es
##   size         - tamaño (0,0 = el tamaño normal de ese tipo)
##   color/accent - colores principal y de detalle (transparente = los normales del tipo)
##   blocks       - si bloquea el paso (Automático = según el tipo)
##   light_energy / light_radius - brillo y alcance de la luz (antorcha, cristal, altar)
##
## El punto de colocación (position) es el CENTRO DE LA BASE del objeto, o sea,
## donde "pisa" el suelo. El objeto se dibuja hacia arriba desde ahí.
## Las manchas de suelo (MANCHA) no bloquean y se dibujan debajo de todo.

enum Kind { ARBOL, ARBOL_SECO, ROCA, ARBUSTO, PILAR, MURO, ANTORCHA, CRISTAL, ALTAR, MANCHA }

const DEFAULT_SIZE := {
	Kind.ARBOL: Vector2(150, 190),
	Kind.ARBOL_SECO: Vector2(120, 200),
	Kind.ROCA: Vector2(90, 64),
	Kind.ARBUSTO: Vector2(90, 56),
	Kind.PILAR: Vector2(56, 150),
	Kind.MURO: Vector2(200, 60),
	Kind.ANTORCHA: Vector2(24, 70),
	Kind.CRISTAL: Vector2(50, 90),
	Kind.ALTAR: Vector2(180, 90),
	Kind.MANCHA: Vector2(300, 160),
}

## Color principal y de detalle de cada tipo.
const DEFAULT_COLOR := {
	Kind.ARBOL: [Color(0.14, 0.34, 0.22), Color(0.22, 0.48, 0.30)],
	Kind.ARBOL_SECO: [Color(0.24, 0.17, 0.14), Color(0.36, 0.28, 0.22)],
	Kind.ROCA: [Color(0.46, 0.46, 0.50), Color(0.62, 0.62, 0.66)],
	Kind.ARBUSTO: [Color(0.18, 0.40, 0.24), Color(0.30, 0.56, 0.32)],
	Kind.PILAR: [Color(0.56, 0.56, 0.62), Color(0.38, 0.38, 0.46)],
	Kind.MURO: [Color(0.46, 0.47, 0.55), Color(0.28, 0.29, 0.37)],
	Kind.ANTORCHA: [Color(0.40, 0.27, 0.16), Color(1.0, 0.65, 0.2)],
	Kind.CRISTAL: [Color(0.35, 0.85, 0.95), Color(0.85, 1.0, 1.0)],
	Kind.ALTAR: [Color(0.50, 0.50, 0.58), Color(0.45, 0.9, 1.0)],
	Kind.MANCHA: [Color(0.3, 0.3, 0.3, 0.35), Color(0, 0, 0, 0)],
}

## Tipos que bloquean el paso de forma normal.
const SOLID_KINDS := [
	Kind.ARBOL, Kind.ARBOL_SECO, Kind.ROCA, Kind.PILAR,
	Kind.MURO, Kind.ANTORCHA, Kind.CRISTAL, Kind.ALTAR,
]

## Alcance (en píxeles) de la luz de los tipos que brillan.
const DEFAULT_LIGHT_RADIUS := {
	Kind.ANTORCHA: 300.0,
	Kind.CRISTAL: 220.0,
	Kind.ALTAR: 280.0,
}

@export var kind: Kind = Kind.ARBOL:
	set(value):
		kind = value
		_refresh()
@export var size: Vector2 = Vector2.ZERO:
	set(value):
		size = value
		_refresh()
@export var color: Color = Color(0, 0, 0, 0):
	set(value):
		color = value
		_refresh()
@export var accent_color: Color = Color(0, 0, 0, 0):
	set(value):
		accent_color = value
		_refresh()
@export_enum("Automático", "Sí", "No") var blocks: int = 0:
	set(value):
		blocks = value
		_refresh()
## Solo para PILAR: dibuja el pilar roto.
@export var broken: bool = false:
	set(value):
		broken = value
		_refresh()

@export_group("Luz")
@export_range(0.0, 3.0, 0.05) var light_energy: float = 1.0
## 0 = alcance normal del tipo.
@export_range(0.0, 800.0, 10.0) var light_radius: float = 0.0

var _light: PointLight2D
var _time: float = 0.0
var _phase: float = 0.0


func _ready() -> void:
	_phase = randf() * TAU
	_refresh()


func _process(delta: float) -> void:
	# Parpadeo suave de la llama o del cristal (solo al jugar).
	if _light == null:
		return
	_time += delta
	var wobble := sin(_time * (11.0 if kind == Kind.ANTORCHA else 3.0) + _phase)
	_light.energy = light_energy * (1.0 + wobble * (0.12 if kind == Kind.ANTORCHA else 0.08))


# --- Valores efectivos -----------------------------------------------------

func _size() -> Vector2:
	if size.x > 0.0 and size.y > 0.0:
		return size
	return DEFAULT_SIZE[kind]


func _main_color() -> Color:
	return color if color.a > 0.0 else DEFAULT_COLOR[kind][0]


func _accent() -> Color:
	return accent_color if accent_color.a > 0.0 else DEFAULT_COLOR[kind][1]


func _is_solid() -> bool:
	if blocks == 1:
		return true
	if blocks == 2:
		return false
	return SOLID_KINDS.has(kind)


## Zona que bloquea el paso, respecto a la base del objeto.
func _collision_rect() -> Rect2:
	var s := _size()
	match kind:
		Kind.ARBOL:
			return Rect2(-12, -14, 24, 16)
		Kind.ARBOL_SECO:
			return Rect2(-10, -12, 20, 14)
		Kind.PILAR:
			return Rect2(-s.x * 0.5, -s.y * 0.3, s.x, s.y * 0.3)
		Kind.MURO, Kind.ALTAR:
			return Rect2(-s.x * 0.5, -s.y, s.x, s.y)
		Kind.ANTORCHA:
			return Rect2(-8, -10, 16, 12)
		Kind.CRISTAL:
			return Rect2(-s.x * 0.35, -s.y * 0.3, s.x * 0.7, s.y * 0.3)
		_:
			return Rect2(-s.x * 0.45, -s.y * 0.75, s.x * 0.9, s.y * 0.75)


# --- Construcción ----------------------------------------------------------

func _refresh() -> void:
	queue_redraw()
	if not is_inside_tree():
		return

	z_index = -5 if kind == Kind.MANCHA else 0
	_rebuild_collision()
	_rebuild_light()


func _rebuild_collision() -> void:
	var old := get_node_or_null("AutoCollision")
	if old != null:
		remove_child(old)
		old.queue_free()

	if not _is_solid() or kind == Kind.MANCHA:
		return

	var rect := _collision_rect()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var node := CollisionShape2D.new()
	node.name = "AutoCollision"
	node.shape = shape
	node.position = rect.get_center()
	add_child(node)


func _rebuild_light() -> void:
	if _light != null:
		remove_child(_light)
		_light.queue_free()
		_light = null

	# En el editor no se crea la luz (solo se vería al activar la iluminación).
	if Engine.is_editor_hint() or not DEFAULT_LIGHT_RADIUS.has(kind) or light_energy <= 0.0:
		return

	var s := _size()
	var radius := light_radius if light_radius > 0.0 else float(DEFAULT_LIGHT_RADIUS[kind])

	_light = PointLight2D.new()
	_light.texture = _light_texture()
	_light.texture_scale = radius / 128.0
	_light.color = _accent() if kind != Kind.CRISTAL else _main_color()
	_light.energy = light_energy
	_light.position = Vector2(0, -s.y * (0.5 if kind != Kind.ANTORCHA else 1.0))
	add_child(_light)


static var _light_tex: GradientTexture2D

static func _light_texture() -> Texture2D:
	if _light_tex == null:
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.set_color(1, Color(1, 1, 1, 0))
		_light_tex = GradientTexture2D.new()
		_light_tex.gradient = gradient
		_light_tex.fill = GradientTexture2D.FILL_RADIAL
		_light_tex.fill_from = Vector2(0.5, 0.5)
		_light_tex.fill_to = Vector2(1.0, 0.5)
		_light_tex.width = 256
		_light_tex.height = 256
	return _light_tex


# --- Dibujo ----------------------------------------------------------------

func _draw() -> void:
	var s := _size()
	var main := _main_color()
	var accent := _accent()

	match kind:
		Kind.ARBOL:
			_draw_tree(s, main, accent)
		Kind.ARBOL_SECO:
			_draw_dead_tree(s, main, accent)
		Kind.ROCA:
			_draw_rock(s, main, accent)
		Kind.ARBUSTO:
			_draw_bush(s, main, accent)
		Kind.PILAR:
			_draw_pillar(s, main, accent)
		Kind.MURO:
			_draw_wall(s, main, accent)
		Kind.ANTORCHA:
			_draw_torch(s, main, accent)
		Kind.CRISTAL:
			_draw_crystal(s, main, accent)
		Kind.ALTAR:
			_draw_altar(s, main, accent)
		Kind.MANCHA:
			_draw_patch(s, main)


func _shadow(width: float, alpha: float = 0.28) -> void:
	draw_set_transform(Vector2(0, -2), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, width, Color(0, 0, 0, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_tree(s: Vector2, main: Color, accent: Color) -> void:
	_shadow(s.x * 0.36)
	var trunk_h := s.y * 0.42
	draw_rect(Rect2(-9, -trunk_h, 18, trunk_h), Color(0.30, 0.20, 0.14))
	draw_rect(Rect2(-9, -trunk_h, 6, trunk_h), Color(0.38, 0.27, 0.18))

	var cy := -s.y * 0.62
	draw_circle(Vector2(-s.x * 0.22, cy + s.y * 0.1), s.x * 0.30, main)
	draw_circle(Vector2(s.x * 0.22, cy + s.y * 0.1), s.x * 0.30, main)
	draw_circle(Vector2(0, cy), s.x * 0.40, main)
	draw_circle(Vector2(-s.x * 0.12, cy - s.y * 0.07), s.x * 0.22, accent)


func _draw_dead_tree(s: Vector2, main: Color, accent: Color) -> void:
	_shadow(s.x * 0.28)
	var h := s.y
	var w := 12.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(-w, 0), Vector2(w, 0), Vector2(w * 0.5, -h * 0.55), Vector2(-w * 0.5, -h * 0.55),
	]), main)
	draw_line(Vector2(0, -h * 0.5), Vector2(0, -h), main, 9.0)
	draw_line(Vector2(0, -h * 0.55), Vector2(-s.x * 0.45, -h * 0.8), main, 7.0)
	draw_line(Vector2(0, -h * 0.4), Vector2(s.x * 0.45, -h * 0.68), main, 7.0)
	draw_line(Vector2(-s.x * 0.45, -h * 0.8), Vector2(-s.x * 0.5, -h * 0.98), main, 4.0)
	draw_line(Vector2(s.x * 0.45, -h * 0.68), Vector2(s.x * 0.52, -h * 0.9), main, 4.0)
	draw_line(Vector2(-w * 0.4, -4), Vector2(-w * 0.3, -h * 0.5), accent, 3.0)


func _draw_rock(s: Vector2, main: Color, accent: Color) -> void:
	_shadow(s.x * 0.5)
	var pts := PackedVector2Array()
	var norm := [Vector2(-0.5, -0.05), Vector2(-0.44, -0.55), Vector2(-0.12, -0.95),
		Vector2(0.26, -0.9), Vector2(0.5, -0.5), Vector2(0.47, -0.05), Vector2(0.1, 0.0)]
	for p in norm:
		pts.append(Vector2(p.x * s.x, p.y * s.y))
	draw_colored_polygon(pts, main)
	draw_polyline(pts + PackedVector2Array([pts[0]]), main.darkened(0.45), 3.0)
	var hi := PackedVector2Array([
		Vector2(-0.34 * s.x, -0.5 * s.y), Vector2(-0.1 * s.x, -0.85 * s.y),
		Vector2(0.18 * s.x, -0.8 * s.y), Vector2(-0.05 * s.x, -0.5 * s.y),
	])
	draw_colored_polygon(hi, accent)


func _draw_bush(s: Vector2, main: Color, accent: Color) -> void:
	_shadow(s.x * 0.45, 0.22)
	draw_circle(Vector2(-s.x * 0.25, -s.y * 0.35), s.y * 0.38, main)
	draw_circle(Vector2(s.x * 0.25, -s.y * 0.35), s.y * 0.38, main)
	draw_circle(Vector2(0, -s.y * 0.5), s.y * 0.46, main)
	draw_circle(Vector2(-s.x * 0.1, -s.y * 0.62), s.y * 0.2, accent)
	draw_circle(Vector2(s.x * 0.2, -s.y * 0.5), s.y * 0.12, accent)


func _draw_pillar(s: Vector2, main: Color, accent: Color) -> void:
	_shadow(s.x * 0.7)
	var base_h := 14.0
	draw_rect(Rect2(-s.x * 0.62, -base_h, s.x * 1.24, base_h), accent)

	if broken:
		var h := s.y * 0.62
		draw_colored_polygon(PackedVector2Array([
			Vector2(-s.x * 0.5, -base_h), Vector2(s.x * 0.5, -base_h),
			Vector2(s.x * 0.5, -h), Vector2(s.x * 0.2, -h - 14.0),
			Vector2(-s.x * 0.05, -h + 6.0), Vector2(-s.x * 0.5, -h - 8.0),
		]), main)
		draw_rect(Rect2(s.x * 0.62, -10, 22, 10), main.darkened(0.15))
		draw_rect(Rect2(s.x * 0.95, -6, 12, 6), main.darkened(0.3))
	else:
		draw_rect(Rect2(-s.x * 0.5, -s.y, s.x, s.y - base_h), main)
		draw_rect(Rect2(-s.x * 0.62, -s.y - 12.0, s.x * 1.24, 14.0), accent)

	var top := -s.y * (0.62 if broken else 1.0) + 14.0
	for i in [-0.25, 0.0, 0.25]:
		draw_line(Vector2(s.x * i, top), Vector2(s.x * i, -base_h - 4.0), main.darkened(0.2), 2.0)


func _draw_wall(s: Vector2, main: Color, accent: Color) -> void:
	var rect := Rect2(-s.x * 0.5, -s.y, s.x, s.y)
	draw_rect(Rect2(rect.position + Vector2(4, 6), rect.size), Color(0, 0, 0, 0.25))
	draw_rect(rect, main)

	# Hiladas de ladrillos.
	var brick := Color(accent, 0.55)
	var row_h := 24.0
	var row := 0
	var y := rect.position.y + row_h
	while y < rect.end.y:
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), brick, 2.0)
		var x := rect.position.x + (48.0 if row % 2 == 0 else 24.0)
		while x < rect.end.x:
			draw_line(Vector2(x, y - row_h), Vector2(x, y), brick, 2.0)
			x += 48.0
		y += row_h
		row += 1

	draw_rect(rect, accent, false, 4.0)


func _draw_torch(s: Vector2, main: Color, accent: Color) -> void:
	_shadow(s.x * 0.9, 0.25)
	draw_rect(Rect2(-4, -s.y, 8, s.y), main)
	draw_rect(Rect2(-9, -s.y - 6, 18, 8), main.darkened(0.25))
	# Llama.
	var tip := Vector2(0, -s.y - 34.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-9, -s.y - 4), Vector2(9, -s.y - 4), Vector2(5, -s.y - 22), tip, Vector2(-5, -s.y - 22),
	]), accent)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-4, -s.y - 4), Vector2(4, -s.y - 4), Vector2(0, -s.y - 24),
	]), Color(1.0, 0.95, 0.6))


func _draw_crystal(s: Vector2, main: Color, accent: Color) -> void:
	_shadow(s.x * 0.6, 0.25)
	draw_circle(Vector2(0, -s.y * 0.45), s.x * 0.9, Color(main, 0.12))
	var w := s.x
	var h := s.y
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -h), Vector2(w * 0.5, -h * 0.45), Vector2(w * 0.3, 0),
		Vector2(-w * 0.3, 0), Vector2(-w * 0.5, -h * 0.45),
	]), main)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -h), Vector2(w * 0.12, -h * 0.45), Vector2(0, 0), Vector2(-w * 0.3, 0),
		Vector2(-w * 0.5, -h * 0.45),
	]), main.lightened(0.15))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-w * 0.12, -h * 0.82), Vector2(-w * 0.02, -h * 0.82), Vector2(-w * 0.12, -h * 0.48),
		Vector2(-w * 0.24, -h * 0.5),
	]), accent)
	# Cristal pequeño al lado.
	draw_colored_polygon(PackedVector2Array([
		Vector2(w * 0.42, -h * 0.5), Vector2(w * 0.62, -h * 0.2), Vector2(w * 0.52, 0), Vector2(w * 0.28, 0),
	]), main.darkened(0.15))


func _draw_altar(s: Vector2, main: Color, accent: Color) -> void:
	_shadow(s.x * 0.62)
	draw_rect(Rect2(-s.x * 0.5, -s.y * 0.5, s.x, s.y * 0.5), main.darkened(0.2))
	draw_rect(Rect2(-s.x * 0.5, -s.y * 0.5, s.x, s.y * 0.5), main.darkened(0.5), false, 3.0)
	draw_rect(Rect2(-s.x * 0.4, -s.y, s.x * 0.8, s.y * 0.55), main)
	draw_rect(Rect2(-s.x * 0.4, -s.y, s.x * 0.8, s.y * 0.55), main.darkened(0.5), false, 3.0)
	# Símbolo brillante.
	var c := Vector2(0, -s.y * 0.72)
	draw_circle(c, s.y * 0.22, Color(accent, 0.25))
	draw_arc(c, s.y * 0.16, 0.0, TAU, 32, accent, 3.0)
	draw_line(c + Vector2(0, -s.y * 0.2), c + Vector2(0, s.y * 0.2), accent, 3.0)
	draw_line(c + Vector2(-s.y * 0.2, 0), c + Vector2(s.y * 0.2, 0), accent, 3.0)


func _draw_patch(s: Vector2, main: Color) -> void:
	draw_set_transform(Vector2(0, -s.y * 0.5), 0.0, Vector2(1.0, s.y / s.x))
	draw_circle(Vector2.ZERO, s.x * 0.5, main)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
