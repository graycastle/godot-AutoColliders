tool
extends Sprite

class_name AutoColliderSprite


export var padding_percent = 100 setget set_padding
export(bool) var regenerate setget regenerate
export(bool) var clear setget clear_collider
export(bool) var freeze


signal property_changed(property, value)


# TODO: Implement the "padding_percent" value that would allow me to increase the size of the collider
# TODO: Determine why the signal in the _set() function causes polygon updates on previous values


func _set(property, value):
	print("Property %s has changed value to %s" % [property, str(value)])
	# Only execute this function in the editor to prevent runtime regeneration
	if Engine.editor_hint:
		generate_collider(true, property, value)


func _exit_tree():
	clear_collider(true)


func set_padding(new_value):
	print("padding_percent has changed to " + str(new_value))
	padding_percent = new_value
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
			var current_padding = self.padding_percent
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
							"padding_percent":
								print("DEBUG: padding_percent was updated")
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
			
			var bitmap_transparency = BitMap.new()
			bitmap_transparency.create_from_image_alpha(sprite_texture)
			
			# Loop through all of the bits in the bitmap and invert to identify transparency
			for i in range(0, bitmap.get_size().y):
				for j in range(0, bitmap.get_size().x):
					bitmap_transparency.set_bit(Vector2(j, i), not bitmap_transparency.get_bit(Vector2(j, i)))
			
			var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()))
			var transparent_polygons = bitmap_transparency.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()))
			
			for polygon in polygons:
				var collider = CollisionPolygon2D.new()
				collider.polygon = polygon
				autocollider.add_child(collider)
			
			# TODO: Figure out how to subtract the transparency polygons from the autocollider
			
			# If we are padding_percent the collider, do so now by scaling it
			if current_padding != 100:
				autocollider.scale.x = current_padding * 0.01
				autocollider.scale.y = current_padding * 0.01
			
			# If the autocollider was padded, scale a copy of this node and get its size
			var autocollider_size = Vector2()
			if current_padding != 100:
				# Create an empty bitmap to the correct scale and get its size
				var autocollider_size_bitmap = BitMap.new()
				autocollider_size_bitmap.create(Vector2(bitmap.get_size().x * (current_padding * 0.01), bitmap.get_size().y * (current_padding * 0.01)))
				autocollider_size = autocollider_size_bitmap.get_size()
			else:
				autocollider_size = bitmap.get_size()

			# Align the polygon to the Sprite's exact position, depending on if its 
			# offset is set to centered
			if current_centered:
				autocollider.position.x = current_position.x - (autocollider_size.x * 0.5)
				autocollider.position.y = current_position.y - (autocollider_size.y * 0.5)
			else:
				autocollider.position = current_position
				# TODO: Determine how to center the autocollider over the sprite when not padded
				if current_padding != 100:
					var width_difference = autocollider_size.x - bitmap.get_size().x
					var height_difference = autocollider_size.y - bitmap.get_size().y
					autocollider.position.x -= width_difference * 0.5
					autocollider.position.y -= height_difference * 0.5
			
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
