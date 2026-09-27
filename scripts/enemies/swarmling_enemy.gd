extends "res://scripts/enemies/enemy_base.gd"
## Éclaireur (Swarmling) : rapide, fragile, fonce droit sur le joueur. La chair à canon du "swarm".

func _ready() -> void:
	max_hp = 12.0
	move_speed = 165.0
	contact_damage = 6.0
	xp_value = 1
	super._ready()
