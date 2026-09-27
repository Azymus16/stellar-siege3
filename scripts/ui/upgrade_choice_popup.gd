extends CanvasLayer
## Popup de sélection d'amélioration : met le jeu en pause visuellement et
## propose 3 cartes ; le joueur en choisit une pour continuer.

signal card_chosen(upgrade: UpgradeData)

@onready var cards: Array = [$Panel/Cards/Card1, $Panel/Cards/Card2, $Panel/Cards/Card3]

var current_choices: Array = []

func _ready() -> void:
	visible = false
	for i in range(cards.size()):
		var btn: Button = cards[i].get_node("SelectButton")
		btn.pressed.connect(_on_card_pressed.bind(i))

func show_choices(choices: Array) -> void:
	current_choices = choices
	for i in range(cards.size()):
		var card = cards[i]
		if i < choices.size():
			var u: UpgradeData = choices[i]
			card.visible = true
			card.get_node("Icon").text = u.icon_letter
			card.get_node("Icon").add_theme_color_override("font_color", u.icon_color)
			card.get_node("TitleLabel").text = u.display_name
			card.get_node("DescLabel").text = u.description
		else:
			card.visible = false
	visible = true

func _on_card_pressed(i: int) -> void:
	if i >= current_choices.size():
		return
	var u: UpgradeData = current_choices[i]
	visible = false
	card_chosen.emit(u)
