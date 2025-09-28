extends PanelContainer

# Preload all the possible category panels this menu can show
const crafting_stations_panel = preload("res://scenes/ui/crafting_stations_ui.tscn")
const fabricator_build_data = preload("res://data/crafting_stations/basic_fabricator.tres")


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
	panel.build_requested.connect(on_build_requested)
	content_container.add_child(panel)

func on_build_requested(building_data: BuildingData):
	# Now have the data and we can pass it to the buildmanager
	BuildManager.enter_build_mode(building_data)
	
	#close the entire menu bar after entering build mode
	#use queue_free() because the GameManager will handle recreating it
	queue_free()
