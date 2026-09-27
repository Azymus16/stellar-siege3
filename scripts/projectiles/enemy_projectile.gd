extends Area2D
## Projectile tiré par les ennemis à distance (Foreur, Boss). Ligne droite, dégâts fixes.

@export var speed: float = 340.0
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.RIGHT
var damage: float = 6.0

func _ready() -> void:
	add_to_group("enemy_projectile")
	collision_layer = 1 << 3 # enemy_projectiles
	collision_mask = 1        # player
	get_tree().create_timer(lifetime).timeout.connect(func(): if is_instance_valid(self): queue_free())

func launch(dir: Vector2, dmg: float) -> void:
	direction = dir.normalized()
	damage = dmg
	rotation = direction.angle()

func get_damage() -> float:
	return damage

func on_hit_player() -> void:
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
