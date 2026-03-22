extends Control
@export var label:Label
@export var pause_button:Button
@export var _game_over_menu:GameOverMenu
@export var _pause_menu:PauseMenu

func _ready() -> void:
	pause_button.pressed.connect(_pause_game)
	_pause_menu.game_unpaused.connect(pause_button.show)
	PlayerStats.death_anim_finished.connect(_on_death)

##TODO: Move this to an autoload, pausing game shouldn't
## happen from this ui node
func _pause_game() -> void:
	pause_button.hide()
	_pause_menu.open()

func _on_death() -> void:
	pause_button.hide()
	_game_over_menu.open()


func _physics_process(_delta: float) -> void:
	label.text = "%.1fs"%PlayerStats.remaining_time
