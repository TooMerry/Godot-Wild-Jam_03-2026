extends Control

@export var particle_texture: Texture2D

var _particles: Array[Particle] = []


func generate(from: Vector2, target: Node2D, amount: int = 1) -> void:
	for i: int in amount:
		var p = Particle.new()
		p.position = from
		p.velocity = Vector2.from_angle(randf() * TAU) * randf_range(40,120)
		p.target = target
		_particles.append(p)


func _process(delta: float) -> void:
	if _particles.is_empty():
		return
	
	for i: int in range(_particles.size() - 1, -1, -1):
		var p = _particles[i]
		var direction = p.target.global_position - p.position
		
		p.time += delta
		if p.time < 1.0:
			p.velocity += direction.normalized() * 256.0 * p.time
		else:
			p.velocity = direction.normalized() * 256.0
		
		p.position += p.velocity * delta
		
		if direction.length() < 8.0:
			_particles.remove_at(i)
	
	queue_redraw()


func _draw():
	for p in _particles:
		draw_texture(particle_texture, p.position)


class Particle:
	var position: Vector2
	var velocity: Vector2
	var target: Node2D
	var time: float
