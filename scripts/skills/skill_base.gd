extends Node2D
class_name SkillBase
## Base commune à toutes les compétences actives déclenchées par le bouton.

var player: Node
var base_cooldown: float = 8.0
var cooldown_reduction: float = 0.0
var current_cd: float = 0.0

func setup(p_player: Node, p_cooldown: float) -> void:
	player = p_player
	base_cooldown = p_cooldown
	current_cd = 0.0

func _process(delta: float) -> void:
	if current_cd > 0.0:
		current_cd = max(0.0, current_cd - delta)
		var eff_cd := get_effective_cooldown()
		EventBus.skill_cooldown_changed.emit(current_cd / max(eff_cd, 0.01))

func get_effective_cooldown() -> float:
	return max(0.6, base_cooldown * (1.0 - cooldown_reduction))

func set_cooldown_reduction(r: float) -> void:
	cooldown_reduction = r

func is_ready() -> bool:
	return current_cd <= 0.0

func try_activate() -> bool:
	if not is_ready():
		return false
	activate()
	current_cd = get_effective_cooldown()
	EventBus.skill_cooldown_changed.emit(1.0)
	return true

func activate() -> void:
	pass # surchargé par les compétences concrètes

func apply_upgrade(param_key: String, value: float) -> void:
	pass # surchargé si besoin
