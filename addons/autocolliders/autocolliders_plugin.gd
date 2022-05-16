tool
extends EditorPlugin


func _enter_tree():
	print("Initializing the AutoCollider node types")
	
	# Get the correct default icon for the node type
	var gui = get_editor_interface().get_base_control()
	var load_icon = gui.get_icon("Sprite", "EditorIcons")
	
	# Add the custom node type to the editor
	add_custom_type("AutoColliderSprite", "Sprite", preload("AutoColliderSprite.gd"), load_icon)
	
	print("AutoCollider node type initialization complete")


func _exit_tree():
	print("De-initializing the AutoCollider node types")
	remove_custom_type("AutoColliderSprite")
	print("AutoCollider node types successfully de-initialized")
