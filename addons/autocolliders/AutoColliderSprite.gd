tool
extends Sprite

class_name AutoColliderSprite


export var padding = 0 setget set_padding
export(bool) var regenerate setget regenerate
export(bool) var clear setget clear_collider
export(bool) var freeze


signal property_changed(property, value)


# TODO: Implement the "padding" value that would allow me to increase the size of the collider
# TODO: Determine why the signal in the _set() function causes polygon updates on previous values


func _set(property, value):
	print("Property %s has changed value to %s" % [property, str(value)])
	# Only execute this function in the editor to prevent runtime regeneration
	if Engine.editor_hint:
		generate_collider(true, property, value)


func _exit_tree():
	clear_collider(true)


func set_padding(new_value):
	print("Padding has changed to " + str(new_value))
	padding = new_value
	if Engine.editor_hint:
		generate_collider(true)


func generate_collider(generate, update_property = '', new_value = ''):
	
		
		# If the node is not frozen and has a texture, fire generation
		if not freeze and self.texture:
			print("Generating collider")
			
			# Clear the existing collider, if present
			clear_collider(true)
			
			# Create an instance of a new CollisionPolygon2D
			print("Creating the new node")
			var autocollider = CollisionPolygon2D.new()
			autocollider.name = self.name + "_autocollider"
			
			# Get the current values of key properties to detect if they've changed
			var current_texture = self.texture
			var current_position = self.position
			var current_centered = self.centered
			var current_padding = self.padding
			var current_flip_h = self.flip_h
			var current_flip_v = self.flip_v
			var current_offset = self.offset
			
			# If update_property is populated, the value is changing. Use new_value
			if update_property != '':
				var all_properties = self.get_property_list()
				for prop in all_properties:
					if prop["name"] == update_property:
						print("FOUND IT!")
						print("Value of current " + prop["name"] + ": " + str(self.get(prop["name"])))
						match prop["name"]:
							"texture":
								print("DEBUG: texture was updated")
								current_texture = new_value
							"position":
								print("DEBUG: position was updated")
								current_position = new_value
							"centered":
								print("DEBUG: Centered was updated to " + str(new_value))
								current_centered = new_value
							"padding":
								print("DEBUG: Padding was updated")
								current_padding = new_value
							"flip_h":
								print("DEBUG: flip_h was updated")
								current_flip_h = new_value
							"flip_v":
								print("DEBUG: flip_v was updated")
								current_flip_v = new_value
							"offset":
								print("DEBUG: Offset was updated")
								current_offset = new_value
			
			# Grab the texture attached to this sprite node, flipping if needed
			var sprite_texture = current_texture.get_data()
			if current_flip_h:
				sprite_texture.flip_x()
			if current_flip_v:
				sprite_texture.flip_y()
			
			# Process the texture into a BitMap
			var bitmap = BitMap.new()
			bitmap.create_from_image_alpha(sprite_texture)
			if current_padding != 0:
				bitmap.grow_mask(current_padding, Rect2(Vector2(0 + current_padding, 0 + current_padding), bitmap.get_size()))
			
			var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0 + current_padding, 0 + current_padding), bitmap.get_size()))
			
			for polygon in polygons:
				var collider = CollisionPolygon2D.new()
				collider.polygon = polygon
				autocollider.add_child(collider)
			
			# Align the polygon to the Sprite's exact position, depending on if its 
			# offset is set to centered
			if current_centered:
				autocollider.global_position.x = current_position.x - (current_texture.get_width() * 0.5) + current_offset.x
				autocollider.global_position.y = current_position.y - (current_texture.get_height() * 0.5) + current_offset.y
			else:
				autocollider.global_position = current_position
			
			# Add the new autocollider to the scene tree as a sibling
			self.get_parent().add_child(autocollider)
		
		else:
			print("Node is frozen or has no texture, no collider generation triggered")


func clear_collider(clear):
	print("Function to clear the sprite's AutoCollider fired")
	# Clear the autocollider only if the node is not frozen
	if not self.freeze:
		var sibling_nodes = self.get_parent().get_children()
		if sibling_nodes.size() > 0:
			print("Node has siblings, checking if collider is already created")
			for node in sibling_nodes:
				print("Current node: " + str(node))
				if node.get_class() == "CollisionPolygon2D" and node.name == self.name + "_autocollider":
					print("Found the collider, removing it")
					node.get_parent().remove_child(node)


func regenerate(regenerate):
	print("regenerating")
	generate_collider(true)
