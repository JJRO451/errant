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
## META EDUCATIVA: el ciclo del agua.
##   fact_*  - "datos": se muestran al recoger un fragmento dorado (campo fact_id de coin.gd).
##   mito_*  - "mitos": los explica un fragmento gris (dirty_fragment.gd) o una Sombra
##             (campo myth_dialogue de enemy.gd) al hacerte daño.
##
## Quién usa cada diálogo:
##   "intro", "forest_intro", "ruins_intro" - cada escenario (propiedad "intro_dialogue" del
##                        nodo raíz) al entrar por primera vez
##   "ending"           - main.gd (al recoger el último fragmento del último escenario)
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
			"Este pueblo tenía una Luz que lo protegía: era el agua que brotaba de la fuente. Se rompió en fragmentos, y las Sombras se alimentan de ellos.",
			"Cada fragmento guarda un recuerdo de cómo viaja el agua. Si los reúnes, quizá la fuente vuelva... y tal vez recuerdes quién eres.",
			"Ojo: los fragmentos dorados son agua limpia, pero los grises están contaminados. No los toques.",
			"Abriré la puerta de la valla. Ten cuidado: las Sombras repiten mentiras sobre el agua, y duelen.",
		],
		"objective": "Recupera los fragmentos dorados (agua limpia) y evita los grises (contaminados).",
	},
	"mara_again": {
		"speaker": "Mara",
		"lines": [
			"Los fragmentos brillan dentro y fuera del pueblo. Los de afuera, tras la valla, son los más peligrosos.",
			"Si te hieren, busca los corazones rosados. Aún guardan algo de calor.",
			"Y recuerda: dorado es agua limpia, gris es agua contaminada.",
		],
	},
	"tomas_first": {
		"speaker": "Tomás",
		"lines": [
			"La fuente dejó de brotar la noche en que la Luz se rompió.",
			"Dicen que si devuelves todos los fragmentos, volverá a correr el agua. Yo solo quiero escucharla otra vez.",
			"Mi abuela decía que el agua es siempre la misma: solo da vueltas. Nunca entendí qué quería decir.",
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
	"forest_intro": {
		"speaker": "",
		"lines": [
			"El bosque se cierra a tu espalda. Las copas tapan hasta la luna.",
			"Entre las raíces brillan fragmentos de luz... y unos ojos que no parpadean.",
		],
		"objective": "Cruza el bosque y recupera los fragmentos: aquí el agua sube hacia el cielo. Las ruinas están al este.",
	},
	"eco_first": {
		"speaker": "Eco",
		"lines": [
			"Shh. Habla bajo: las Sombras oyen mejor que ven.",
			"Yo también busqué la Luz, hace mucho. Ahora solo repito lo que el bosque me susurra.",
			"Los árboles beben del suelo y le devuelven el agua al cielo. Por eso aquí el aire siempre está húmedo.",
			"Al este hay unas ruinas. Dicen que allí nació la Luz. Si quieres recordar quién eres, ve.",
		],
	},
	"eco_again": {
		"speaker": "Eco",
		"lines": [
			"Sigue el camino y no te quedes quieto. Lo que se queda quieto, se queda aquí.",
		],
	},
	"forest_sign": {
		"speaker": "Letrero",
		"lines": [
			"«Los árboles recuerdan a quien los cruza.»",
		],
	},
	"forest_exit_sign": {
		"speaker": "Letrero",
		"lines": [
			"«Ruinas del Origen — a 100 pasos. Vuelve si aún tienes miedo.»",
		],
	},
	"ruins_intro": {
		"speaker": "",
		"lines": [
			"Bajo las raíces despierta una piedra muy antigua. Cristales azules laten como un corazón dormido.",
			"Aquí empezó todo. Lo sabes sin saber cómo.",
		],
		"objective": "Reúne los fragmentos de las ruinas. El último espera en el santuario del este.",
	},
	"ruins_sign": {
		"speaker": "Letrero",
		"lines": [
			"«Aquí la Luz aprendió a ser Luz.»",
			"Debajo, grabado con prisa: «No la lleves lejos. Se rompe.»",
		],
	},
	"ruins_altar": {
		"speaker": "",
		"lines": [
			"El altar del centro está vacío. Tiene la forma exacta de algo que ya no está.",
			"Pasas la mano por el símbolo y el aire vibra, como si te reconociera.",
		],
	},
	"ruins_sanctum": {
		"speaker": "",
		"lines": [
			"El santuario late más fuerte. Queda un último fragmento.",
		],
	},
	"ending": {
		"speaker": "",
		"lines": [
			"Al tocar el último fragmento, la luz estalla y recorre las ruinas, el bosque y todo Villaluz.",
			"Entiendes el viaje completo: el agua se evapora, se condensa, cae, corre y se infiltra... y vuelve a empezar.",
			"En la plaza, la fuente vuelve a brotar... y por un instante lo recuerdas todo.",
			"Pero la visión se desvanece. El camino continúa. El errante no se detiene.",
		],
	},
	# --- Datos del ciclo del agua (fragmentos dorados) ---
	"fact_planeta": {
		"speaker": "Dato",
		"lines": [
			"El agua cubre cerca del 71 % de la superficie de la Tierra.",
			"Por eso a nuestro planeta se le llama «el planeta azul».",
		],
	},
	"fact_dulce": {
		"speaker": "Dato",
		"lines": [
			"Casi toda el agua del planeta (97 %) es salada. Solo cerca del 3 % es dulce.",
			"Y esa agua dulce es la que usamos para beber, cocinar y regar.",
		],
	},
	"fact_hielo": {
		"speaker": "Dato",
		"lines": [
			"La mayor parte del agua dulce está congelada en glaciares o guardada bajo tierra.",
			"En ríos y lagos, lo que más usamos, hay menos del 1 % del agua dulce.",
		],
	},
	"fact_evap": {
		"speaker": "Dato",
		"lines": [
			"El Sol calienta el agua de mares, ríos y lagos, y una parte se convierte en vapor.",
			"A ese paso de líquido a vapor se le llama EVAPORACIÓN.",
		],
	},
	"fact_plantas": {
		"speaker": "Dato",
		"lines": [
			"Las plantas también devuelven agua al aire: la sueltan por sus hojas en forma de vapor.",
			"Eso se llama TRANSPIRACIÓN.",
		],
	},
	"fact_mismo": {
		"speaker": "Dato",
		"lines": [
			"El ciclo del agua no crea ni destruye agua: es la misma que bebieron los dinosaurios.",
			"Solo cambia de lugar y de estado: líquido, vapor o hielo.",
		],
	},
	"fact_vapor": {
		"speaker": "Dato",
		"lines": [
			"El vapor de agua es ligero y sube por el aire.",
			"Mientras sube, se va enfriando.",
		],
	},
	"fact_nube": {
		"speaker": "Dato",
		"lines": [
			"Al enfriarse, el vapor vuelve a convertirse en gotitas diminutas: eso es la CONDENSACIÓN.",
			"Millones de gotitas juntas forman una nube.",
		],
	},
	"fact_rocio": {
		"speaker": "Dato",
		"lines": [
			"La condensación también ocurre cerca del suelo: el rocío de la mañana son gotitas de vapor sobre las hojas.",
			"Un vaso de agua fría «suda» por la misma razón.",
		],
	},
	"fact_bosque": {
		"speaker": "Dato",
		"lines": [
			"Los bosques ayudan a mantener la lluvia de una región: sus hojas liberan vapor y sus raíces retienen el agua.",
			"Talar un bosque entero puede traer sequías.",
		],
	},
	"fact_lluvia": {
		"speaker": "Dato",
		"lines": [
			"Cuando las gotas de una nube pesan demasiado, caen: es la PRECIPITACIÓN.",
			"Puede ser lluvia, granizo o nieve, según la temperatura.",
		],
	},
	"fact_rio": {
		"speaker": "Dato",
		"lines": [
			"Parte del agua que cae corre sobre el suelo hacia arroyos y ríos: es el ESCURRIMIENTO.",
			"Los ríos la llevan al mar... y el ciclo vuelve a empezar.",
		],
	},
	"fact_acuifero": {
		"speaker": "Dato",
		"lines": [
			"Otra parte se mete en la tierra: es la INFILTRACIÓN.",
			"Se guarda bajo tierra en los ACUÍFEROS, y rellenarlos puede tardar años, incluso siglos.",
		],
	},
	"fact_cuidar": {
		"speaker": "Dato",
		"lines": [
			"Cuidar el agua cuesta poco: cierra la llave mientras te cepillas, repara las fugas y no tires basura ni aceite al drenaje.",
			"Así el agua que le devolvemos al ciclo sigue siendo limpia.",
		],
	},
	# --- Mitos que corrige un fragmento gris (contaminado) ---
	"mito_basura": {
		"speaker": "Mito",
		"lines": [
			"«Tirar basura al río no pasa nada: la corriente se la lleva.»",
			"Falso. La corriente solo la lleva a otro lugar: contamina el agua y daña a todo lo que vive en ella.",
		],
	},
	"mito_llave": {
		"speaker": "Mito",
		"lines": [
			"«Dejar la llave abierta mientras te cepillas no importa.»",
			"Falso. Una llave abierta puede gastar hasta 12 litros por minuto. Ciérrala mientras te cepillas.",
		],
	},
	"mito_talar": {
		"speaker": "Mito",
		"lines": [
			"«Los árboles solo gastan agua. Mejor talarlos todos.»",
			"Falso. Los bosques protegen el suelo, ayudan a que el agua se infiltre y devuelven humedad al aire.",
		],
	},
	"mito_aceite": {
		"speaker": "Mito",
		"lines": [
			"«El aceite de cocina se puede tirar por el fregadero.»",
			"Falso. Un solo litro de aceite puede contaminar cientos de litros de agua. Guárdalo en una botella y llévalo a reciclar.",
		],
	},
	"mito_pozo": {
		"speaker": "Mito",
		"lines": [
			"«El agua del subsuelo es infinita: sácala sin límite.»",
			"Falso. Si se saca más rápido de lo que se infiltra, los acuíferos se agotan y el suelo puede hundirse.",
		],
	},
	"mito_hervir": {
		"speaker": "Mito",
		"lines": [
			"«Si el agua se ve sucia, basta con hervirla y quedará limpia.»",
			"Falso. Hervir mata microbios, pero no quita químicos, metales ni basura.",
		],
	},
	# --- Mitos que repiten las Sombras al hacerte daño ---
	"mito_infinita": {
		"speaker": "Sombra",
		"lines": [
			"«El agua es infinita. Gasta todo lo que quieras.»",
			"Falso. Solo cerca del 3 % del agua del planeta es dulce, y la mayor parte no es fácil de usar.",
		],
	},
	"mito_mar": {
		"speaker": "Sombra",
		"lines": [
			"«Con tanto mar, nunca faltará agua para beber.»",
			"Falso. El agua de mar es salada y no se puede beber. Quitarle la sal cuesta mucha energía.",
		],
	},
	"mito_nubes": {
		"speaker": "Sombra",
		"lines": [
			"«Las nubes son humo. No tienen nada de agua.»",
			"Falso. Una nube son millones de gotitas diminutas de agua flotando en el aire.",
		],
	},
	"mito_solo_rio": {
		"speaker": "Sombra",
		"lines": [
			"«El agua solo está en los ríos y los lagos.»",
			"Falso. También está en el aire, en las plantas, en los glaciares y bajo tierra.",
		],
	},
	"mito_pierde": {
		"speaker": "Sombra",
		"lines": [
			"«El agua que usas desaparece para siempre.»",
			"Falso. El agua no desaparece, pero si se contamina deja de servir para beber o para regar.",
		],
	},
	"mito_cuidar_igual": {
		"speaker": "Sombra",
		"lines": [
			"«Da igual cuidar el agua: siempre lloverá lo mismo.»",
			"Falso. Las sequías y la contaminación cambian cuánta agua limpia tenemos. Cuidarla sí importa.",
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


## Ids de todos los datos educativos del juego (los que empiezan con "fact_").
static func fact_ids() -> Array:
	return DIALOGUES.keys().filter(func(id: String) -> bool: return id.begins_with("fact_"))


## Cuántos datos ha descubierto ya el jugador en esta partida.
static func facts_learned() -> int:
	return fact_ids().filter(func(id: String) -> bool: return has_flag("done_" + id)).size()
