extends Node2D

@onready var pet_container = $PetContainer
@onready var ui = $Ui/Panel

var selected_color = Color("2d2469")

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
		"color": selected_color
	}

	var pet = preload("res://Centipede.tscn").instantiate()

	pet.setup(settings)
	pet.position = get_viewport_rect().size / 2
	$PetContainer.add_child(pet)
