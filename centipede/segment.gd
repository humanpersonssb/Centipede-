extends Node2D

var main_scene: Node = null

@onready var body = $Body
@onready var overlay = $Body/Overlay
@onready var left_leg = $LeftLeg
@onready var right_leg = $RightLeg
@onready var antennae_l = $AntennaeL
@onready var antennae_r = $AntennaeR
@onready var click_area = $ClickArea
@onready var shape = $ClickArea/Shape

var blood_textures = [
	preload("res://assets/splatter_1.png"),
	preload("res://assets/splatter_2.png"),
	preload("res://assets/splatter_3.png"),
]
var blood_node: Node = null

var index: int = 0
var seg_size: float = 1.0
var is_head: bool = false
var prev_segment = null
var next_segment = null
var exploded: bool = false

var flying_parts: Array = []

var dead_parts_node: Node = null

func setup(data, seg_index, texture, dead_parts, blood):
	main_scene = get_tree().current_scene
	blood_node = blood
	dead_parts_node = dead_parts
	index = seg_index
	seg_size = data.size
	is_head = seg_index == 0

	body.texture = texture
	body.scale = Vector2.ONE * data.size * 0.05
	body.self_modulate = data.color
	body.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

	overlay.texture = preload("res://assets/gradient_inner.png")
	overlay.scale = Vector2.ONE
	overlay.modulate = data.secondary_color

	var leg_tex = preload("res://assets/leg_bent.png")
	left_leg.texture = leg_tex
	left_leg.scale = Vector2.ONE * data.size * 0.05 * data.legs
	left_leg.scale.x = -left_leg.scale.x
	left_leg.modulate = data.secondary_color
	left_leg.offset = Vector2(0, -leg_tex.get_height() / 2.0)

	right_leg.texture = leg_tex
	right_leg.scale = Vector2.ONE * data.size * 0.05 * data.legs
	right_leg.modulate = data.secondary_color
	right_leg.offset = Vector2(0, -leg_tex.get_height() / 2.0)

	var ant_tex = preload("res://assets/leg_lowerarm.png")
	if is_head:
		antennae_l.texture = ant_tex
		antennae_l.scale = Vector2.ONE * data.size * 0.05
		antennae_l.scale.y = data.antenna * 0.05
		antennae_l.modulate = data.secondary_color
		antennae_l.offset = Vector2(0, -ant_tex.get_height() / 2.0)

		antennae_r.texture = ant_tex
		antennae_r.scale = Vector2.ONE * data.size * 0.05
		antennae_r.scale.y = data.antenna * 0.05
		antennae_r.modulate = data.secondary_color
		antennae_r.offset = Vector2(0, -ant_tex.get_height() / 2.0)
	else:
		antennae_l.visible = false
		antennae_r.visible = false

	var collision_shape = CircleShape2D.new()
	collision_shape.radius = 14.0 * data.size
	shape.shape = collision_shape
	click_area.input_pickable = true
	click_area.connect("input_event", _on_area_input)

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		on_clicked()

func on_clicked():
	#print(index)
	if exploded:
		return
	explode()
	await get_tree().create_timer(0.1).timeout
	if prev_segment:
		prev_segment.propagate(-1)
	if next_segment:
		next_segment.propagate(1)


func propagate(direction: int):
	if not exploded:
		explode()
		
		
		
	await get_tree().create_timer(0.05).timeout
	
	if direction == -1 and prev_segment:
		prev_segment.propagate(-1)
	if direction == 1 and next_segment:
		next_segment.propagate(1)




func explode():
	if exploded:
		return
	main_scene.add_shake(2.0)
	exploded = true
	click_area.input_pickable = false

	var parts = [body, left_leg, right_leg]
	if is_head:
		parts.append(antennae_l)
		parts.append(antennae_r)

	for part in parts:
		if not is_instance_valid(part) or not part.visible:
			continue
		var velocity = Vector2(randf_range(-120, 120), randf_range(-120, 120))
		var spin = randf_range(-5.0, 5.0)
		var velocity_drag = randf_range(2, 10)
		var spin_drag = randf_range(3, 5.0)
		var is_body = part == body
		part.reparent(dead_parts_node)
		flying_parts.append({ "node": part, "velocity": velocity, "spin": spin, "velocity_drag": velocity_drag, "spin_drag": spin_drag, "is_body": is_body })


	#blood
	#var splatter = Sprite2D.new()
	#splatter.texture = blood_textures[randi() % blood_textures.size()]
	#splatter.rotation = randf_range(0, TAU)
	#
	#splatter.modulate = Color("#e861c5")
	#
	#splatter.scale = Vector2.ONE * seg_size*randf_range(0.05, 0.2)
	#blood_node.add_child(splatter)
	#splatter.global_position = global_position

func _process(delta):
	for part in flying_parts:
		if not is_instance_valid(part.node):
			continue
		part.node.global_position += part.velocity * delta
		part.node.rotation += part.spin * delta
		part.velocity = part.velocity.lerp(Vector2.ZERO, delta * part.velocity_drag)
		part.spin = lerpf(part.spin, 0.0, delta * part.spin_drag)
		
		#blood trails
		if part.is_body and part.velocity.length() > 0.05 and is_instance_valid(blood_node):
			var splatter = Sprite2D.new()
			splatter.texture = blood_textures[randi() % blood_textures.size()]
			splatter.rotation = randf_range(0, TAU)
			splatter.scale = Vector2.ONE * seg_size *part.velocity.length() *0.001
			splatter.modulate =  Color("#e861c5")
			blood_node.add_child(splatter)
			splatter.global_position = part.node.global_position

func update_transform(pos: Vector2, rot: float, wiggle: float):
	if exploded:
		return

	global_position = pos
	body.rotation = rot

	var angle = rot - PI / 2.0
	var forward = Vector2(cos(angle), sin(angle))
	var right = Vector2(-forward.y, forward.x)
	var radius = 14.0 * seg_size

	left_leg.global_position = pos - right * radius * 0.5
	left_leg.rotation = rot - PI / 2.0 + wiggle

	right_leg.global_position = pos + right * radius * 0.5
	right_leg.rotation = rot + PI / 2.0 + wiggle

	if is_head:
		antennae_l.global_position = pos
		antennae_r.global_position = pos
		antennae_l.rotation = rot + PI / 6.0 + wiggle / 3.0
		antennae_r.rotation = rot - PI / 6.0 - wiggle / 3.0
