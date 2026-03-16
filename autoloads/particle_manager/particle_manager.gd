extends Control

@export var particle_texture: Texture2D
@export var distance_threshold: float = 32.0
@export var acceleration_time: float = 1.0
@export var acceleration_factor: float = 256.0
@export var final_velocity: float = 1024.0

var _particles: Array[Particle] = []


func _process(delta: float) -> void:
	if _particles.is_empty():
		return
	
	for i: int in range(_particles.size() - 1, -1, -1):
		var p = _particles[i]
		var direction = p.target.global_position - p.position
		if direction.length() < distance_threshold:
			_particles.remove_at(i)
		else:
			p.time += delta
			if p.time < acceleration_time:
				p.velocity += direction.normalized() * acceleration_factor * p.time
			else:
				p.velocity = direction.normalized() * final_velocity
			
			p.position += p.velocity * delta
	
	queue_redraw()


func _draw():
	for p in _particles:
		draw_texture(particle_texture, p.position)


func generate(from: Vector2, target: Node2D, amount: int = 1) -> void:
	for i: int in amount:
		var p = Particle.new()
		p.position = from
		p.velocity = Vector2.from_angle(randf() * TAU) * randf_range(40.0, 120.0)
		p.target = target
		_particles.append(p)


class Particle:
	var position: Vector2
	var velocity: Vector2
	var target: Node2D
	var time: float
