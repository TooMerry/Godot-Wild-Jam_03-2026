extends Node

@export var bgm_player: AudioStreamPlayer
@export var sfx_container: Node
@export var max_sfx_players: int = 16
@export var sfx_bus_name: StringName = &"Sfx"

var _available_sfx_players: Array[AudioStreamPlayer] = []
var _busy_sfx_players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for child: Node in sfx_container.get_children():
		if child is AudioStreamPlayer:
			var sfx_player: AudioStreamPlayer = child
			sfx_player.finished.connect(_on_sfx_player_finished.bind(sfx_player))
			_available_sfx_players.push_back(child)
	var bgm_stream:AudioStream = load("uid://14blugiu46by")
	bgm_player.finished.connect(play_bgm.bind(bgm_stream))
	play_bgm(bgm_stream)


func play_bgm(stream: AudioStream) -> void:
	if bgm_player.playing:
		bgm_player.stop()
	bgm_player.set_stream(stream)
	bgm_player.play()


func play_sfx(stream: AudioStream, with_random_pitch: bool = false) -> void:
	if _available_sfx_players.is_empty():
		_create_sfx_player()
	
	var sfx_player: AudioStreamPlayer = _available_sfx_players.pop_back()
	sfx_player.set_stream(stream)
	sfx_player.set_bus(sfx_bus_name)
	if with_random_pitch:
		sfx_player.set_pitch_scale(randf_range(0.8, 1.2))
	else:
		sfx_player.set_pitch_scale(1.0)
	
	_busy_sfx_players.push_back(sfx_player)
	sfx_player.play()


func stop_all_sfx() -> void:
	for sfx_player: AudioStreamPlayer in _busy_sfx_players:
		sfx_player.stop()
		if _available_sfx_players.size() > max_sfx_players:
			sfx_player.queue_free.call_deferred()
		else:
			_available_sfx_players.push_back(sfx_player)
	
	_busy_sfx_players.clear()


func _create_sfx_player() -> void:
	var sfx_player := AudioStreamPlayer.new()
	sfx_player.finished.connect(_on_sfx_player_finished.bind(sfx_player))
	sfx_container.add_child(sfx_player)
	_available_sfx_players.push_back(sfx_player)


func _on_sfx_player_finished(sfx_player: AudioStreamPlayer) -> void:
	var sfx_player_count: int = _available_sfx_players.size() + _busy_sfx_players.size()
	if sfx_player_count > max_sfx_players:
		sfx_player.queue_free.call_deferred()
	else:
		_available_sfx_players.push_back(sfx_player)
	
	_busy_sfx_players.erase(sfx_player)
