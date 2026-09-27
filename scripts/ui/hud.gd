extends CanvasLayer
## HUD : relie le joystick virtuel et le bouton de compétence au joueur,
## affiche PV / XP / niveau / timer de vague / barre de vie du boss.
## Le rendu de recharge du bouton de compétence se fait par simple teinte
## (modulate) du bouton lui-même : pas besoin de calque séparé.

@onready var joystick = $Joystick
@onready var skill_button: TouchScreenButton = $SkillButton
@onready var health_bar: ProgressBar = $HealthBar
@onready var xp_bar: ProgressBar = $XPBar
@onready var level_label: Label = $LevelLabel
@onready var timer_label: Label = $TimerLabel
@onready var boss_bar_container: Control = $BossBar
@onready var boss_bar: ProgressBar = $BossBar/ProgressBar
@onready var boss_name_label: Label = $BossBar/NameLabel

var player: Node = null

func _ready() -> void:
	joystick.moved.connect(_on_joystick_moved)
	skill_button.pressed.connect(_on_skill_pressed)
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.skill_cooldown_changed.connect(_on_cooldown_changed)
	EventBus.wave_timer_changed.connect(_on_wave_timer_changed)
	EventBus.boss_spawned.connect(_on_boss_spawned)
	EventBus.boss_died.connect(_on_boss_died)
	boss_bar_container.visible = false

func set_player(p: Node) -> void:
	player = p

func _process(_delta: float) -> void:
	if player and is_instance_valid(player):
		xp_bar.max_value = player.xp_to_next
		xp_bar.value = player.xp
		level_label.text = "Niv. %d" % player.level
	if boss_bar_container.visible:
		var boss := get_tree().get_first_node_in_group("boss")
		if boss and is_instance_valid(boss):
			boss_bar.max_value = boss.max_hp
			boss_bar.value = boss.current_hp

func _on_joystick_moved(v: Vector2) -> void:
	if player and is_instance_valid(player):
		player.set_move_input(v)

func _on_skill_pressed() -> void:
	if player and is_instance_valid(player):
		player.try_activate_skill()

func _on_health_changed(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current

func _on_cooldown_changed(ratio: float) -> void:
	# ratio = 1.0 juste après activation, redescend vers 0.0 quand la compétence est prête.
	var darkness: float = clamp(ratio, 0.0, 1.0) * 0.6
	skill_button.modulate = Color(1.0 - darkness, 1.0 - darkness, 1.0 - darkness, 1.0)

func _on_wave_timer_changed(seconds: float) -> void:
	var mm: int = int(seconds) / 60
	var ss: int = int(seconds) % 60
	timer_label.text = "%02d:%02d" % [mm, ss]

func _on_boss_spawned(boss_name: String) -> void:
	boss_bar_container.visible = true
	boss_name_label.text = boss_name

func _on_boss_died() -> void:
	boss_bar_container.visible = false
