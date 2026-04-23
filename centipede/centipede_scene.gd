extends Node2D

@onready var pet_container = $PetContainer
@onready var ui = $Ui/Panel

var selected_color = Color.GREEN

func _ready():

	$Ui/Panel/Generate.pressed.connect(_generate)
	$Ui/Panel/Color.pressed.connect(func(): selected_color = Color.RED)
	$Ui/Panel/Color2.pressed.connect(func(): selected_color = Color.BLUE)
	$Ui/Panel/Color3.pressed.connect(func(): selected_color = Color.GREEN)
	$Ui/Panel/Color4.pressed.connect(func(): selected_color = Color.YELLOW)
	$Ui/Panel/Color5.pressed.connect(func(): selected_color = Color.PURPLE)
	$Ui/Panel/Color6.pressed.connect(func(): selected_color = Color.ORANGE)
	$Ui/Panel/Color7.pressed.connect(func(): selected_color = Color.CYAN)
	$Ui/Panel/Color8.pressed.connect(func(): selected_color = Color.HOT_PINK)

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

	$PetContainer.add_child(pet)
