extends Node2D

@onready var pet_container = $PetContainer

@onready var alive = $PetContainer/Alive
@onready var dead = $PetContainer/Dead
@onready var blood = $PetContainer/Blood



var selected_color = Color("2d2469")
var selected_secondary_color = Color("504581")

func _ready():
	$Ui/Panel/Generate.pressed.connect(_generate)
	$Ui/Panel/Color.pressed.connect(func(): selected_color = Color("2d2469"))
	$Ui/Panel/Color2.pressed.connect(func(): selected_color = Color("473562"))
	$Ui/Panel/Color3.pressed.connect(func(): selected_color = Color("355363"))
	$Ui/Panel/Color4.pressed.connect(func(): selected_color = Color("684c64"))
	$Ui/Panel/Color5.pressed.connect(func(): selected_color = Color("305b52"))
	$Ui/Panel/Color6.pressed.connect(func(): selected_color = Color("645d3c"))
	$Ui/Panel/Color7.pressed.connect(func(): selected_color = Color("39363f"))
	$Ui/Panel/Color8.pressed.connect(func(): selected_color = Color("424e2a"))
	$Ui/Panel/Color9.pressed.connect(func(): selected_secondary_color = Color("504581"))
	$Ui/Panel/Color10.pressed.connect(func(): selected_secondary_color = Color("8a566c"))
	$Ui/Panel/Color11.pressed.connect(func(): selected_secondary_color = Color("988264"))
	$Ui/Panel/Color12.pressed.connect(func(): selected_secondary_color = Color("456863"))
	$Ui/Panel/Color13.pressed.connect(func(): selected_secondary_color = Color("623911"))
	$Ui/Panel/Color14.pressed.connect(func(): selected_secondary_color = Color("846d7e"))
	$Ui/Panel/Color15.pressed.connect(func(): selected_secondary_color = Color("626624"))
	$Ui/Panel/Color16.pressed.connect(func(): selected_secondary_color = Color("1b5761"))

func _generate():
	var panel = $Ui/Panel
	var dropdown = $Ui/Panel/TypeDropdown
	var settings = {
		"type": dropdown.get_item_text(dropdown.selected).to_lower(),
		"size": panel.get_node("SizeSlider").value,
		"segments": int(panel.get_node("SegmentSlider").value),
		"spacing": panel.get_node("SpacingSlider").value,
		"antenna": panel.get_node("AntennaSlider").value,
		"legs": panel.get_node("LegSlider").value,
		"tail": panel.get_node("TailSlider").value,
		"color": selected_color,
		"secondary_color": selected_secondary_color
	}
	var pet = preload("res://Centipede.tscn").instantiate()
	pet.position = get_viewport_rect().size / 2
	alive.add_child(pet)
	pet.setup(settings)
	
	
#scrreenshoake	
@onready var camera = $Camera2D

var shake_amount: float = 0.0

func add_shake(amount: float):
	shake_amount += amount

func _process(delta):
	if shake_amount > 0:
		camera.offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
		shake_amount = lerpf(shake_amount, 0.0, delta * 10.0)
	else:
		camera.offset = Vector2.ZERO
