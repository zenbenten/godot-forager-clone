# data/item_data.gd
class_name ItemData
extends Resource

#different categories an item can belong to
enum ItemType {
	RESOURCE,
	TOOL,
	FOOD,
	MATERIAL,
	VALUABLE
}

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var max_stack_size: int = 64
@export var type: ItemType
