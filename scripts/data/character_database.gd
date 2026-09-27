extends Node
## CharacterDatabase (autoload) : liste centrale des personnages jouables.
## Pour ajouter un personnage : une ligne ici + un WeaponXxx.gd + un SkillXxx.gd.

var characters: Dictionary = {}
var order: Array[String] = ["nova", "orion", "lyra", "comete"]

func _ready() -> void:
	_build()

func _build() -> void:
	characters["nova"] = CharacterData.make(
		"nova", "Nova", "Plasma dévastateur, pluie de météores",
		Color(1.0, 0.55, 0.25), "res://assets/sprites/characters/nova.svg",
		100.0, 220.0, 12.0,
		"plasma", "meteor", "Pluie de Météores", 8.0
	)
	characters["orion"] = CharacterData.make(
		"orion", "Orion", "Ondes gravitationnelles, trou noir",
		Color(0.55, 0.65, 1.0), "res://assets/sprites/characters/orion.svg",
		130.0, 190.0, 9.0,
		"gravity", "blackhole", "Trou Noir", 12.0
	)
	characters["lyra"] = CharacterData.make(
		"lyra", "Lyra", "Tirs stellaires rebondissants, constellation explosive",
		Color(0.85, 0.5, 1.0), "res://assets/sprites/characters/lyra.svg",
		90.0, 230.0, 8.0,
		"stellar", "constellation", "Constellation Explosive", 10.0
	)
	characters["comete"] = CharacterData.make(
		"comete", "Comète", "Glace perforante, dash traînée de givre",
		Color(0.5, 0.9, 1.0), "res://assets/sprites/characters/comete.svg",
		95.0, 260.0, 10.0,
		"ice", "dash", "Éclat de Givre", 5.0
	)

func get_character(id: String) -> CharacterData:
	return characters.get(id, characters[order[0]])

func get_ordered_list() -> Array[CharacterData]:
	var list: Array[CharacterData] = []
	for id in order:
		list.append(characters[id])
	return list
