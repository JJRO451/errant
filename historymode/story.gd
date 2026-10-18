class_name Story
extends RefCounted
## Texto y estado de la historia.
##
## TODO el texto del juego vive en DIALOGUES: puedes escribir y cambiar la
## historia aquí sin tocar escenas. Cada diálogo tiene:
##   speaker   - quién habla ("" = narrador, no muestra nombre)
##   lines     - las líneas, una tras otra
##   flag      - (opcional) bandera extra que se activa al terminar
##   objective - (opcional) objetivo nuevo que se muestra en pantalla al terminar
##
## Al terminar CUALQUIER diálogo se activa sola la bandera "done_<id>".
## Con ella sabes qué ya pasó: Story.has_flag("done_mara_first").
##
## Quién usa cada diálogo:
##   "intro" y "ending" - main.gd (al empezar y al recoger el último fragmento)
##   los demás          - NPC (npc.tscn) o disparadores (story_trigger.gd) por su id
##                        (están colocados en main.tscn)

const DIALOGUES := {
	"intro": {
		"speaker": "",
		"lines": [
			"Llegas a un pueblo en silencio. La fuente de la plaza está seca y las ventanas, cerradas.",
			"Solo la casa del extremo oeste tiene una luz encendida.",
		],
		"objective": "Habla con la anciana de la casa del oeste (acércate y pulsa E).",
	},
	"mara_first": {
		"speaker": "Mara",
		"lines": [
			"Un viajero... Hacía años que nadie cruzaba la valla del este.",
			"Este pueblo tenía una Luz que lo protegía. Se rompió en fragmentos, y las Sombras se alimentan de ellos.",
			"Si los reúnes, quizá la Luz vuelva... y tal vez recuerdes quién eres.",
			"Abriré la puerta de la valla. Ten cuidado: allá afuera no todo lo que se mueve es amigo.",
		],
		"objective": "Recupera los fragmentos de luz (las monedas amarillas).",
	},
	"mara_again": {
		"speaker": "Mara",
		"lines": [
			"Los fragmentos brillan dentro y fuera del pueblo. Los de afuera, tras la valla, son los más peligrosos.",
			"Si te hieren, busca los corazones rosados. Aún guardan algo de calor.",
		],
	},
	"tomas_first": {
		"speaker": "Tomás",
		"lines": [
			"La fuente dejó de brotar la noche en que la Luz se rompió.",
			"Dicen que si devuelves todos los fragmentos, volverá a correr el agua. Yo solo quiero escucharla otra vez.",
		],
	},
	"gate_locked": {
		"speaker": "",
		"lines": [
			"La puerta de la valla está cerrada con un candado oxidado.",
			"Quizá Mara, la anciana del oeste, sepa cómo abrirla.",
		],
	},
	"enter_outskirts": {
		"speaker": "",
		"lines": [
			"Más allá de la valla el aire se vuelve frío. Entre los árboles, algo te observa.",
		],
	},
	"sign_welcome": {
		"speaker": "Letrero",
		"lines": [
			"«Villaluz. Aquí la luz nunca se apagaba.»",
			"Alguien tachó la última palabra y escribió debajo: «...hasta ahora.»",
		],
	},
	"sign_pond": {
		"speaker": "Letrero",
		"lines": [
			"«No beber del estanque. El agua escucha.»",
		],
	},
	"ending": {
		"speaker": "",
		"lines": [
			"Al tocar el último fragmento, la luz estalla y recorre todo Villaluz.",
			"En la plaza, la fuente vuelve a brotar... y por un instante lo recuerdas todo.",
			"Pero la visión se desvanece. El camino continúa. El errante no se detiene.",
		],
	},
}

## Banderas de la historia: qué ya pasó. Ejemplo: "done_mara_first".
static var flags: Dictionary = {}
## Objetivo actual, se muestra en pantalla (vacío = no se muestra).
static var objective: String = ""


## Borra todo el progreso de la historia.
static func reset() -> void:
	flags.clear()
	objective = ""


static func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value


static func has_flag(flag_name: String) -> bool:
	return bool(flags.get(flag_name, false))


## Devuelve los datos de un diálogo, o un diccionario vacío si no existe.
static func get_dialogue(id: String) -> Dictionary:
	if not DIALOGUES.has(id):
		push_warning("Story: no existe el diálogo '%s'." % id)
		return {}
	return DIALOGUES[id]
