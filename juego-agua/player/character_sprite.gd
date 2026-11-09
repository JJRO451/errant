class_name CharacterSprite
extends Sprite2D
## Personaje animado con una hoja de sprites (spritesheet). Lo usan el jugador,
## los NPC y los enemigos, y reemplaza a character_art.gd (que dibujaba con código).
##
## Cómo usarlo: pon este script en un nodo Sprite2D, asigna la imagen en "Texture"
## y en "Animation" indica cuántas columnas (Hframes) y filas (Vframes) tiene la hoja.
##
## Disposición por defecto de la hoja:
##   - Cada COLUMNA es un fotograma de la animación de caminar (izquierda → derecha).
##   - Cada FILA es una dirección, de arriba abajo: abajo, izquierda, derecha, arriba.
## Si tu hoja usa otro orden, cambia los números de "Filas de la hoja" (row_down...).
## Si falta una dirección lateral pon -1 y se usará la contraria volteada.
## Si la hoja tiene una sola fila (p. ej. un monstruo que flota), no hace falta nada más.
##
## Quien mueve al personaje solo tiene que llamar cada fotograma:
##     sprite.set_motion(direccion_de_movimiento)

enum Facing { DOWN, LEFT, RIGHT, UP }

@export_group("Animación")
## Cuántas columnas de la fila se usan al caminar (0 = todas las de la hoja).
@export var walk_frames: int = 0
## Columna que se muestra cuando el personaje está quieto.
@export var idle_frame: int = 0
## Fotogramas por segundo de la animación de caminar.
@export var fps: float = 8.0
## true = se sigue animando aunque no se mueva (por ejemplo, un enemigo que flota).
@export var animate_when_idle: bool = false

@export_group("Filas de la hoja")
@export var row_down: int = 0
@export var row_left: int = 1
@export var row_right: int = 2
@export var row_up: int = 3
## Hojas con una sola dirección de lado: voltear horizontalmente al mirar a la izquierda.
@export var mirror_left: bool = false

## Hacia dónde mira ahora (valores de Facing).
var facing: int = Facing.DOWN

var _time: float = 0.0
var _moving: bool = false


func _ready() -> void:
	_apply_frame()


func _process(delta: float) -> void:
	if _moving or animate_when_idle:
		_time += delta * fps
	else:
		_time = 0.0
	_apply_frame()


## Indica hacia dónde se mueve el personaje (Vector2.ZERO = quieto).
## Cambia la dirección a la que mira y activa o detiene la animación de caminar.
func set_motion(direction: Vector2) -> void:
	_moving = direction.length_squared() > 0.01
	if _moving:
		face(direction)


## Hace que mire hacia esa dirección sin animarlo.
func face(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return

	if absf(direction.x) >= absf(direction.y):
		facing = Facing.RIGHT if direction.x > 0.0 else Facing.LEFT
	else:
		facing = Facing.DOWN if direction.y > 0.0 else Facing.UP


## Hace que mire hacia una de las cuatro direcciones (valores de Facing: 0 abajo,
## 1 izquierda, 2 derecha, 3 arriba) y actualiza la imagen al instante.
func set_facing(new_facing: int) -> void:
	facing = clampi(new_facing, Facing.DOWN, Facing.UP)
	_apply_frame()


func _apply_frame() -> void:
	if texture == null:
		return

	var columns := maxi(hframes, 1)
	var rows := maxi(vframes, 1)
	var count := clampi(walk_frames if walk_frames > 0 else columns, 1, columns)

	var column := clampi(idle_frame, 0, columns - 1)
	if _moving or animate_when_idle:
		column = int(_time) % count

	var row := 0
	var flip := false
	match facing:
		Facing.DOWN:
			row = row_down
		Facing.UP:
			row = row_up
		Facing.LEFT:
			if row_left >= 0:
				row = row_left
			else:
				row = row_right
				flip = true
			if mirror_left:
				flip = true
		Facing.RIGHT:
			if row_right >= 0:
				row = row_right
			else:
				row = row_left
				flip = true

	flip_h = flip
	frame_coords = Vector2i(column, clampi(row, 0, rows - 1))
