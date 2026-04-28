extends Node2D

var segments = []
var trail = []
var dir = Vector2.RIGHT
var speed = 50
var segment_count = 8
var spacing = 18
var target_dir = Vector2.RIGHT

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

var gradiant_texture = preload("res://assets/gradient_inner.png")
var leg_texture = preload("res://assets/leg_bent.png")
var antennae_texture = preload("res://assets/leg_lowerarm.png")
var leg_texture_flipped = preload("res://assets/leg_bent_flipped.png")

func setup(data):
	segment_count = data.segments
	spacing = data.spacing
	speed = randf_range(80, 160)
	dir = Vector2.RIGHT.rotated(randf_range(0, TAU))

	for seg in segments:
		if seg.has("node") and is_instance_valid(seg.node):
			seg.node.queue_free()
	segments.clear()

	var pool = spiky_textures if data.type == "spiky" else smooth_textures
	var chosen_texture = pool[randi() % pool.size()]

	for i in range(segment_count):
		
		
		
		
		#legs
		var left_leg = Sprite2D.new()
		left_leg.texture = leg_texture_flipped
		left_leg.scale = Vector2.ONE *data.size*0.05*data.legs
		left_leg.modulate = data.secondary_color
		left_leg.offset = Vector2(0, -left_leg.texture.get_height() / 2.0)
		add_child(left_leg)
		
		var right_leg = Sprite2D.new()
		right_leg.texture = leg_texture
		right_leg.scale = Vector2.ONE *data.size*0.05*data.legs
		right_leg.modulate = data.secondary_color
		right_leg.offset = Vector2(0, -left_leg.texture.get_height() / 2.0)
		add_child(right_leg)
		
		
		#antaneea
		var antennaeL = null
		var antennaeR = null
		if(i == 0):
			antennaeL = Sprite2D.new()
			antennaeL.texture = antennae_texture
			antennaeL.scale = Vector2.ONE *data.size*0.05
			antennaeL.scale.y = data.antenna*0.05
			antennaeL.modulate = data.secondary_color
			antennaeL.offset = Vector2(0, -antennaeL.texture.get_height() / 2.0)
			add_child(antennaeL)
			
			antennaeR = Sprite2D.new()
			antennaeR.texture = antennae_texture
			antennaeR.scale = Vector2.ONE *data.size*0.05
			antennaeL.scale.y = data.antenna*0.05
			antennaeR.modulate = data.secondary_color
			antennaeR.offset = Vector2(0, -antennaeR.texture.get_height() / 2.0)
			add_child(antennaeR)
		
		var sprite = Sprite2D.new()
		sprite.texture = chosen_texture
		sprite.scale = Vector2.ONE * data.size * 0.05
		sprite.self_modulate = data.color
		
		#gradiant thing
		sprite.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
		var overlay = Sprite2D.new()
		overlay.texture = gradiant_texture
		overlay.scale = Vector2.ONE
		overlay.modulate = data.secondary_color
		sprite.add_child(overlay)
		
		add_child(sprite)
		

		segments.append({
			"pos": position,
			"index": i,
			"size": data.size,
			"color": data.color,
			"secondary_color": data.secondary_color,
			"type": data.type,
			"antenna": data.antenna,
			"legs": data.legs,
			"tail": data.tail,
			"node": sprite,
			"left_leg": left_leg,
			"right_leg": right_leg,
			"antennaeL": antennaeL,
			"antennaeR": antennaeR
		})

func _process(delta):
	move_head(delta)
	update_trail()
	update_segments()
	update_sprite_transforms()
	queue_redraw()

var turn_timer = 0.0

func move_head(delta):
	turn_timer -= delta
	if turn_timer <= 0:
		turn_timer = randf_range(0.5, 2.0)
		target_dir = dir.rotated(deg_to_rad(randf_range(-50, 50)))


	var turn_speed = 3.0
	dir = dir.slerp(target_dir, turn_speed * delta)

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
	for i in range(segment_count):
		var idx = i * spacing
		if idx < trail.size():
			segments[i].pos = trail[idx]

func update_sprite_transforms():
	for i in range(segment_count):
		var seg = segments[i]
		if not is_instance_valid(seg.node):
			continue
		seg.node.global_position = seg.pos
		if i == 0:
			seg.node.rotation = dir.angle() + PI / 2.0
		elif segments[i - 1].pos != seg.pos:
			var face = (segments[i - 1].pos - seg.pos).normalized()
			seg.node.rotation = face.angle() + PI / 2.0
		
		
		#legs
		var angle = seg.node.rotation - PI/2
		var forward = Vector2(cos(angle),sin(angle))
		var right = Vector2(-forward.y,forward.x)
		var radius = 14*seg.size
		var t = Time.get_ticks_msec() / 200.0
		var wiggle = sin(t + i) * 0.3
		
		seg.left_leg.global_position = seg.pos - right * radius * 0.5
		seg.left_leg.rotation = seg.node.rotation - PI / 2.0 + wiggle

		seg.right_leg.global_position = seg.pos + right * radius * 0.5
		seg.right_leg.rotation = seg.node.rotation + PI / 2.0 + wiggle
		
		
		#antnea
		if (seg.index==0):
			seg.antennaeL.rotation = seg.node.rotation +PI/6 + wiggle/3
			seg.antennaeR.rotation = seg.node.rotation  -PI/6- wiggle/3 
		

func _draw():
	var t = Time.get_ticks_msec() / 200.0
	for i in range(segment_count):
		var seg = segments[i]
		var p = to_local(seg.pos)
		var is_head = i == 0
		var is_tail = i == segment_count - 1
		var color = seg.color
		var secondary_color = seg.secondary_color
		var size = seg.size
		var leg_len = seg.legs
		var antenna_len = seg.antenna
		var tail_len = seg.tail
		var wiggle = sin(t + i) * (6.0 * size)
		var radius = 14.0 * size
		
		#angle of segment for leg placement
		#var angle = seg.node.rotation - PI / 2.0
		#var forward = Vector2(cos(angle), sin(angle))
		#var right = Vector2(-forward.y, forward.x)

		#legs LINE OLD VERSION!!
		#var left_root = p - right * radius * 0.5
		#draw_line(
		#	left_root,
		#	left_root - right * leg_len * size * 2.0 + forward * wiggle,
		#	secondary_color, 2.0
		#)
		#var right_root = p + right * radius * 0.5
		#draw_line(
		#	right_root,
		#	right_root + right * leg_len * size * 2.0 - forward * wiggle,
		#	secondary_color, 2.0
		#)

		#if is_head:
			#draw_line(
				#p + Vector2(-radius * 0.3, -radius * 0.6),
				#p + Vector2(-antenna_len * 0.5 * size, -antenna_len * size + wiggle),
				#color,
				#2.0
			#)
			#draw_line(
				#p + Vector2(radius * 0.3, -radius * 0.6),
				#p + Vector2(antenna_len * 0.5 * size, -antenna_len * size - wiggle),
				#color,
				#2.0
			#)
			#draw_circle(
				#p + Vector2(-radius * 0.25, -radius * 0.1),
				#max(1.5, radius * 0.12),
				#Color.BLACK
			#)
			#draw_circle(
				#p + Vector2(radius * 0.25, -radius * 0.1),
				#max(1.5, radius * 0.12),
				#Color.BLACK
			#)
#
		#if is_tail:
			#draw_line(
				#p + Vector2(0, radius * 0.7),
				#p + Vector2(0, tail_len * size),
				#color,
				#3.0
			#)
