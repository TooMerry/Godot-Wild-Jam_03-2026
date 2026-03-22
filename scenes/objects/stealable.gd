@abstract class_name Stealable
extends AnimatableBody2D
var time_transfer_multiplier:float = 1.
@abstract func steal(seconds:float) -> float
@abstract func give(seconds:float) -> float
@abstract func set_highlight(enabled:bool) -> void
