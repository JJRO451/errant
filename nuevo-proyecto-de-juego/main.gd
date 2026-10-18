extends Node2D

## Archivo aparte de las opciones (settings.cfg), para no pisarse con el menú.
const RECORDS_PATH := "user://records.cfg"

var score: int = 0
var total_coins: int = 0
var finished: bool = false

## Segundos transcurridos en la partida actual.
var elapsed: float = 0.0
## Mejor tiempo guardado. -1 significa que aún no hay récord.
var best_time: float = -1.0

var pause_menu: PauseMenu
var _last_health: int = 0

@onready var score_label: Label = $ScoreLabel
@onready var health_label: Label = $HealthLabel
@onready var time_label: Label = $TimeLabel
@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	# Menú de pausa / victoria (se construye por código, ver pause_menu.gd).
	pause_menu = PauseMenu.new()
	add_child(pause_menu)

	var coins = get_tree().get_nodes_in_group("coins")
	total_coins = coins.size()

	for coin in coins:
		coin.connect("collected", _on_coin_collected)

	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)

	_load_best_time()
	_last_health = player.health

	score_label.text = "Monedas: 0 / %d" % total_coins
	_update_health_label(player.health, player.max_health)
	_update_time_label()


func _process(delta: float) -> void:
	# Al pausar el árbol, _process se detiene solo y el tiempo no corre.
	if finished:
		return

	elapsed += delta
	_update_time_label()


func _unhandled_input(event: InputEvent) -> void:
	# Esc (o B del mando) abre la pausa.
	if event.is_action_pressed("ui_cancel") and not finished and not pause_menu.is_open():
		pause_menu.open("Pausa", true)
		get_viewport().set_input_as_handled()


func _on_coin_collected() -> void:
	if finished:
		return

	score += 1

	if score >= total_coins:
		_win()
	else:
		score_label.text = "Monedas: %d / %d" % [
			score,
			total_coins
		]


func _win() -> void:
	finished = true
	score_label.text = "¡GANASTE!"

	var subtitle := "Tiempo: %s" % _format_time(elapsed)
	if best_time < 0.0 or elapsed < best_time:
		best_time = elapsed
		_save_best_time()
		subtitle += "\n¡Nuevo récord!"
	else:
		subtitle += "\nMejor: %s" % _format_time(best_time)

	_update_time_label()
	# Pausa el juego (el jugador deja de moverse) y muestra las opciones.
	pause_menu.open("¡Ganaste!", false, "Jugar de nuevo", subtitle)


func _on_player_health_changed(current: int, maximum: int) -> void:
	_update_health_label(current, maximum)

	# Temblor de pantalla solo al perder vida (no al curarse).
	if current < _last_health:
		_shake_camera(16.0 if current <= 0 else 9.0)
	_last_health = current


func _on_player_died() -> void:
	if finished:
		return

	finished = true
	score_label.text = "¡PERDISTE!"
	pause_menu.open("Game Over", false, "Intentar de nuevo", "Tiempo: %s" % _format_time(elapsed))


# --- Interfaz ---------------------------------------------------------------

func _update_health_label(current: int, maximum: int) -> void:
	health_label.text = "Vidas: %d / %d" % [current, maximum]


func _update_time_label() -> void:
	var text := "Tiempo: %s" % _format_time(elapsed)
	if best_time >= 0.0:
		text += "   Mejor: %s" % _format_time(best_time)
	time_label.text = text


func _format_time(seconds: float) -> String:
	return "%.1f s" % seconds


# --- Efectos ----------------------------------------------------------------

func _shake_camera(strength: float = 9.0, duration: float = 0.3) -> void:
	var tween := create_tween()
	# Que el temblor termine aunque el juego se pause justo después (al morir).
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	var steps := 8
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		var shake := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength * falloff
		tween.tween_property(camera, "offset", shake, duration / steps)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)


# --- Récord -----------------------------------------------------------------

func _load_best_time() -> void:
	var config := ConfigFile.new()
	if config.load(RECORDS_PATH) == OK:
		best_time = config.get_value("records", "best_time", -1.0)


func _save_best_time() -> void:
	var config := ConfigFile.new()
	# Se carga primero por si más adelante se guardan más datos en el mismo archivo.
	config.load(RECORDS_PATH)
	config.set_value("records", "best_time", best_time)
	config.save(RECORDS_PATH)
