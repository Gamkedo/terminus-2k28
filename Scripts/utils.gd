# Contains various static utility functions to be called from elsewhere
class_name Utils
extends Node

## Hide/show billboard graphics based on direction
static func apply_billboard_graphics(graphic_toward: VisualInstance3D,
	graphic_away: VisualInstance3D, direction: Vector3) -> void:
		# toggle which graphic to show, moving towards or away from camera
		graphic_toward.visible = direction.z>0
		graphic_away.visible = !graphic_toward.visible

## Hide/show billboard graphics, and also turn left/right based on direction
static func apply_billboard_flip_graphics(graphic_toward: VisualInstance3D,
	graphic_away: VisualInstance3D, direction: Vector3) -> void:
		# Start with front/back billboarding
		apply_billboard_graphics(graphic_toward, graphic_away, direction)
		
		# make sprite look left/right based on movement direction
		var cam_rot = graphic_toward.get_viewport().get_camera_3d().rotation.y
		# adjusted_x_rot to account for camera being rotated
		var adjusted_x_rot = direction.x * cos(cam_rot) - direction.z * sin(cam_rot)
		var flip = (adjusted_x_rot < 0)
		graphic_toward.flip_h = flip
		graphic_away.flip_h = flip

#region Tree Traversal Utilities

static func up_tree_in_group(leaf: Node, group: StringName) -> Node:
	return up_tree_matching(leaf, func(node: Node) -> bool: return node.is_in_group(group) )
	
static func up_tree_with_type(leaf: Node, type: Variant) -> Node:
	return up_tree_matching(leaf, func(node: Node) -> bool: return is_instance_of(node, type) )
	
static func up_tree_matching(leaf: Node, predicate:Callable) -> Node:
	var node:Node = leaf
	while node:
		if predicate.call(node):
			return node
		node = node.get_parent()
	return null
	
static func down_tree_in_group(root: Node, group: StringName, return_on_first:bool=false) -> Array[Node]:
	return down_tree_matching(root, func(node: Node) -> bool: return node.is_in_group(group), return_on_first)
	
static func down_tree_in_group_single(root: Node, group: StringName) -> Node:
	var children := down_tree_in_group(root, group, true)
	return null if children.is_empty() else children.front()
	
static func down_tree_with_type(root: Node, type: Variant, return_on_first:bool=false) -> Array[Node]:
	return down_tree_matching(root, func(node: Node) -> bool: return is_instance_of(node, type), return_on_first)

static func down_tree_with_type_single(root: Node, type: Variant) -> Node:
	return down_tree_with_type(root, type, true).front()
	
static func down_tree_matching(root: Node, predicate: Callable, return_on_first:bool=false) -> Array[Node]:
	var stack:Array[Node] = [root]
	var matching_nodes:Array[Node] = []
	
	while not stack.is_empty():
		var node:Node = stack.pop_back()
		if predicate.call(node):
			matching_nodes.push_back(node)
			if return_on_first:
				return matching_nodes
		stack.append_array(node.get_children())
	return matching_nodes
#endregion

## Projects a 3d vector onto the xz plane
static func grid_vector(v:Vector3) -> Vector2:
	return Vector2(v.x, v.z)
