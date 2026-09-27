extends Node
## GameManager : état global qui survit aux changements de scène.
## Stocke le personnage sélectionné et les infos de fin de run.

var selected_character_id: String = "nova"

# Résultat de la dernière run, pour l'écran de fin.
var last_run_time: float = 0.0
var last_run_level: int = 1
var last_run_kills: int = 0
var last_run_victory: bool = false

# Réglages généraux, faciles à retoucher pour l'équilibrage.
const BOSS_SPAWN_TIME: float = 240.0 # 4 minutes -> apparition du boss
const ARENA_RADIUS: float = 1400.0 # rayon jouable de l'arène

func start_run(character_id: String) -> void:
	selected_character_id = character_id
	last_run_time = 0.0
	last_run_level = 1
	last_run_kills = 0
	last_run_victory = false

func report_run_end(time_survived: float, level_reached: int, kills: int, victory: bool) -> void:
	last_run_time = time_survived
	last_run_level = level_reached
	last_run_kills = kills
	last_run_victory = victory
