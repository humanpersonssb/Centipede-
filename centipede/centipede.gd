extends Node2D

var segments: Array = []
var trail: Array = []
var dir = Vector2.RIGHT
var speed = 50
var segment_count = 8
var spacing = 18
var target_dir = Vector2.RIGHT
var turn_timer = 0.0


var smooth_textures = [
	preload("res://assets/segment_smooth_bumps.png"),
	preload("res://assets/segment_smooth_diamond.png"),
	preload("res://assets/segment_smooth_hourglass.png"),
	preload("res://assets/segment_smooth_moon.png"),
	preload("res://assets/segment_smooth_trapezoid.png"),
]
var spiky_textures = [
	preload("res://assets/segment_spiky_bumps.png"),
	preload("res://assets/segment_spiky_diamond.png"),
	preload("res://assets/segment_spiky_hourglass.png"),
	preload("res://assets/segment_spiky_moon.png"),
	preload("res://assets/segment_spiky_trapezoid.png"),
]

func setup(data):
	segment_count = data.segments
	spacing = data.spacing
	speed = randf_range(80, 90)
	dir = Vector2.RIGHT.rotated(randf_range(0, TAU))

	for seg in segments:
		if is_instance_valid(seg):
			seg.queue_free()
	segments.clear()
	trail.clear()

	var pool = spiky_textures if data.type == "spiky" else smooth_textures
	var chosen_texture = pool[randi() % pool.size()]

	for i in range(segment_count):
		var seg = preload("res://Segment.tscn").instantiate()
		add_child(seg)
		var dead_parts = get_tree().current_scene.get_node("PetContainer/Dead")
		var blood = get_tree().current_scene.get_node("PetContainer/Blood")
		
		
		
		seg.setup(data, i, chosen_texture, dead_parts,blood)
		segments.append(seg)

	for i in range(segment_count):
		segments[i].prev_segment = segments[i - 1] if i > 0 else null
		segments[i].next_segment = segments[i + 1] if i < segment_count - 1 else null

func _process(delta):
	move_head(delta)
	update_trail()
	update_segments()

func move_head(delta):
	turn_timer -= delta
	if turn_timer <= 0:
		turn_timer = randf_range(0.5, 2.0)
		target_dir = dir.rotated(deg_to_rad(randf_range(-50, 50)))

	dir = dir.slerp(target_dir, 3.0 * delta)
	position += dir.normalized() * speed * delta

	var screen = get_viewport_rect().size
	if position.x < 0 or position.x > screen.x:
		dir.x *= -1
		target_dir.x *= -1
	if position.y < 0 or position.y > screen.y:
		dir.y *= -1
		target_dir.y *= -1

func update_trail():
	trail.insert(0, position)
	if trail.size() > 1000:
		trail.pop_back()

func update_segments():
	var t = Time.get_ticks_msec() / 200.0
	for i in range(segment_count):
		var idx = i * spacing
		if idx >= trail.size():
			continue

		var pos = trail[idx]
		var rot: float
		if i == 0:
			rot = dir.angle() + PI / 2.0
		else:
			var prev_pos = trail[(i - 1) * spacing]
			if prev_pos != pos:
				rot = (prev_pos - pos).normalized().angle() + PI / 2.0
			else:
				rot = segments[i].body.rotation

		var wiggle = sin(t + i) * 0.3
		segments[i].update_transform(pos, rot, wiggle)
