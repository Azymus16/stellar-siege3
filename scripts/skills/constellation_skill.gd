extends "res://scripts/skills/skill_base.gd"
## Constellation Explosive (Lyra) : place plusieurs nœuds autour du joueur
## qui explosent en chaîne peu après.

var node_count: int = 6
var node_radius: float = 75.0
var damage_mult: float = 1.0
var spawn_ring: float = 190.0

func activate() -> void:
	var dmg: float = player.get_effective_damage() * 1.3 * damage_mult
	for i in range(node_count):
		var angle: float = TAU * float(i) / float(node_count)
		var pos: Vector2 = player.global_position + Vector2.RIGHT.rotated(angle) * spawn_ring
		var delay: float = 0.45 + float(i) * 0.08
		var scene: PackedScene = load("res://scenes/projectiles/ConstellationNode.tscn")
		var n := scene.instantiate()
		player.get_tree().current_scene.add_child(n)
		n.setup(pos, dmg, node_radius, delay)

func apply_upgrade(param_key: String, value: float) -> void:
	match param_key:
		"extra_node":
			node_count += int(value)
		"damage_mult":
			damage_mult += value
		_:
			pass
