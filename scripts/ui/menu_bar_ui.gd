extends PanelContainer

# Preload all the possible category panels this menu can show
const crafting_stations_panel = preload("res://scenes/ui/crafting_stations_ui.tscn")


@onready var content_container = %CategoryContentContainer
@onready var crafting_button = %CraftingStations

func _ready():
	#connect the button signals to functions
	crafting_button.pressed.connect(show_crafting_stations)

func _clear_content():
	for child in content_container.get_children():
		child.queue_free()

func show_crafting_stations():
	_clear_content()
	var panel = crafting_stations_panel.instantiate()
	content_container.add_child(panel)
