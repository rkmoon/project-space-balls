extends Node
class_name children_utils

static func get_all_children(in_node, arr := []):
    for child in in_node.get_children():
        arr.push_back(child)
        arr = get_all_children(child, arr)
    return arr