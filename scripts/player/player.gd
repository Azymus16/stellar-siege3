extends CharacterBody2D
## Player : contrôle le déplacement, les stats, la progression et branche
## dynamiquement l'arme + la compétence correspondant au personnage choisi.

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurt_box: Area2D = $HurtBox
@onready var weapon_slot: Node2D = $WeaponSlot
@onready var skill_slot: Node2D = $SkillSlot
@onready var invuln_timer: Timer = $InvulnTimer

var character_data: CharacterData

# --- Stats de base (issues du personnage) ---
var base_move_speed: float
var base_damage: float
var max_hp: float
var current_hp: float

# --- Multiplicateurs cumulés par les upgrades ---
var damage_multiplier: float = 1.0
var attack_speed_multiplier: float = 1.0
var move_speed_multiplier: float = 1.0
var armor: float = 0.0
var pickup_radius_mult: float = 1.0
var skill_cooldown_reduction: float = 0.0 # fraction 0..0.7
var xp_gain_mult: float = 1.0
var regen_per_sec: float = 0.0

# --- Progression ---
var level: int = 1
var xp: float = 0.0
var xp_to_next: float = 10.0
var taken_upgrade_counts: Dictionary = {}
var kill_count: int = 0

# --- Input ---
var move_input: Vector2 = Vector2.ZERO # fourni par le joystick virtuel (ou clavier en test)
var is_dead: bool = false
var is_dashing: bool = false # true pendant le dash de Comète : la compétence prend le contrôle du déplacement

var weapon: Node2D
var skill: Node2D

const BASE_PICKUP_RADIUS: float = 90.0
var _regen_accum: float = 0.0

func setup(p_character: CharacterData) -> void:
	character_data = p_character
	base_move_speed = p_character.move_speed
	base_damage = p_character.base_damage
	max_hp = p_character.max_hp
	current_hp = max_hp

	if ResourceLoader.exists(p_character.sprite_path):
		sprite.texture = load(p_character.sprite_path)
	sprite.modulate = Color(1, 1, 1)

	collision_layer = 1 # player
	collision_mask = 0
	hurt_box.collision_layer = 0
	hurt_box.collision_mask = (1 << 1) | (1 << 3) # enemies (layer2) + enemy_projectiles (layer4)

	_spawn_weapon(p_character.weapon_id)
	_spawn_skill(p_character.skill_id, p_character.skill_cooldown)

	EventBus.player_health_changed.emit(current_hp, max_hp)

func _spawn_weapon(weapon_id: String) -> void:
	var path := "res://scripts/weapons/%s_weapon.gd" % weapon_id
	var script := load(path)
	var node := Node2D.new()
	node.name = "Weapon"
	node.set_script(script)
	weapon_slot.add_child(node)
	weapon = node
	weapon.setup(self)

func _spawn_skill(skill_id: String, cooldown: float) -> void:
	var path := "res://scripts/skills/%s_skill.gd" % skill_id
	var script := load(path)
	var node := Node2D.new()
	node.name = "Skill"
	node.set_script(script)
	skill_slot.add_child(node)
	skill = node
	skill.setup(self, cooldown)

func _ready() -> void:
	hurt_box.body_entered.connect(_on_hurt_body_entered)
	hurt_box.area_entered.connect(_on_hurt_area_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if move_input.length() > 0.05:
		sprite.rotation = move_input.angle() + PI / 2.0

	if is_dashing:
		return # la compétence de dash pilote directement global_position

	var effective_speed: float = base_move_speed * move_speed_multiplier
	velocity = move_input * effective_speed
	move_and_slide()

	if regen_per_sec > 0.0 and current_hp < max_hp:
		_regen_accum += regen_per_sec * delta
		if _regen_accum >= 1.0:
			var whole: float = floor(_regen_accum)
			_regen_accum -= whole
			heal(whole)

func set_move_input(v: Vector2) -> void:
	move_input = v

func try_activate_skill() -> void:
	if skill and not is_dead:
		skill.try_activate()

func get_pickup_radius() -> float:
	return BASE_PICKUP_RADIUS * pickup_radius_mult

func get_effective_damage() -> float:
	return base_damage * damage_multiplier

# ---------------- Dégâts / soins ----------------

func _on_hurt_body_entered(body: Node) -> void:
	if body.is_in_group("enemy_contact"):
		var dmg: float = 8.0
		if body.has_method("get_contact_damage"):
			dmg = body.get_contact_damage()
		take_damage(dmg)

func _on_hurt_area_entered(area: Node) -> void:
	if area.is_in_group("enemy_projectile"):
		var dmg: float = 6.0
		if area.has_method("get_damage"):
			dmg = area.get_damage()
		take_damage(dmg)
		if area.has_method("on_hit_player"):
			area.on_hit_player()

func take_damage(amount: float) -> void:
	if is_dead or not invuln_timer.is_stopped():
		return
	var reduced: float = max(1.0, amount - armor)
	current_hp -= reduced
	current_hp = max(current_hp, 0.0)
	EventBus.player_health_changed.emit(current_hp, max_hp)
	invuln_timer.start(0.35)
	_flash_hit()
	if current_hp <= 0.0:
		die()

func heal(amount: float) -> void:
	current_hp = min(max_hp, current_hp + amount)
	EventBus.player_health_changed.emit(current_hp, max_hp)

func _flash_hit() -> void:
	sprite.modulate = Color(1, 0.4, 0.4)
	var t := get_tree().create_timer(0.15)
	t.timeout.connect(func(): if is_instance_valid(sprite): sprite.modulate = Color(1, 1, 1))

func die() -> void:
	if is_dead:
		return
	is_dead = true
	EventBus.player_died.emit()

# ---------------- XP / niveaux ----------------

func add_xp(amount: float) -> void:
	if is_dead:
		return
	xp += amount * xp_gain_mult
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = 10.0 + float(level - 1) * 6.0
		EventBus.player_leveled_up.emit(level)

func register_kill() -> void:
	kill_count += 1

# ---------------- Upgrades ----------------

func apply_upgrade(u: UpgradeData) -> void:
	taken_upgrade_counts[u.id] = taken_upgrade_counts.get(u.id, 0) + 1

	match u.stat_key:
		"damage_mult":
			damage_multiplier += u.value
		"attack_speed_mult":
			attack_speed_multiplier += u.value
		"move_speed_mult":
			move_speed_multiplier += u.value
		"max_hp_flat":
			max_hp += u.value
			current_hp += u.value
			EventBus.player_health_changed.emit(current_hp, max_hp)
		"armor_flat":
			armor += u.value
		"pickup_radius_mult":
			pickup_radius_mult += u.value
		"skill_cooldown_mult":
			skill_cooldown_reduction = min(0.7, skill_cooldown_reduction + u.value)
			if skill:
				skill.set_cooldown_reduction(skill_cooldown_reduction)
		"xp_gain_mult":
			xp_gain_mult += u.value
		"regen_flat":
			regen_per_sec += u.value
		_:
			pass

	if u.param_key != "":
		if u.requires_weapon != "" and weapon and weapon.has_method("apply_upgrade"):
			weapon.apply_upgrade(u.param_key, u.value)
		elif u.requires_skill != "" and skill and skill.has_method("apply_upgrade"):
			skill.apply_upgrade(u.param_key, u.value)
