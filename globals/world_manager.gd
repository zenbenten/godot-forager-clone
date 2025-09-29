extends Node

@rpc("any_peer", "call_local", "reliable")
func destroy_object_rpc(object_path: NodePath):
	var object_to_destroy = get_node_or_null(object_path)
	if object_to_destroy:
		print("Destroying object at path: ", object_path)
		object_to_destroy.queue_free()
