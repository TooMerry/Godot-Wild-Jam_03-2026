class_name VolumeSlider
extends HSlider

@export var bus_name: StringName = &"Master"

var _bus_index: int = 0


func _ready() -> void:
	_bus_index = AudioServer.get_bus_index(bus_name)
	value = AudioServer.get_bus_volume_linear(_bus_index)
	value_changed.connect(_on_value_changed)


func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_linear(_bus_index, new_value)
