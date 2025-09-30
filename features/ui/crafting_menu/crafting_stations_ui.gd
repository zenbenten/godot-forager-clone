extends Control

#tefine a custom signal that will carry a BuildingData resource when emitted
signal build_requested(building_data: BuildingData)

#this scene is respontsible for its own buildable items
@export var fabricator_build_data: BuildingData
#TODO: add more stuff

#get a reference to the button within this scene
@onready var fabricator_button = %BasicFabricator

func _ready():
	# when the button is pressed call local function.
	fabricator_button.pressed.connect(on_fabricator_button_pressed)

func on_fabricator_button_pressed():
	# instead of calling the BuildManager directly just emit signal
	#pass the data for the fabricator along with the signal
	build_requested.emit(fabricator_build_data)
