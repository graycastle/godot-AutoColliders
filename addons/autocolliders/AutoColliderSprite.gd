tool
extends Sprite


export var padding_percent = 100 setget set_padding
export(bool) var regenerate setget regenerate
export(bool) var clear setget clear_collider
export(bool) var freeze


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
			var current_values = {
				"texture" : self.texture,
				"position" : self.position,
				"centered" : self.centered,
				"padding_percent" : self.padding_percent,
				"flip_h" : self.flip_h,
				"flip_v" : self.flip_v,
				"offset" : self.offset,
				"rotation_degrees" : self.rotation_degrees,
				"scale" : self.scale,
				"z_index" : self.z_index
			}
			
			# If update_property is populated, the value is changing. Use new_value
			if update_property != '':
				var all_properties = self.get_property_list()
				for prop in all_properties:
					if prop["name"] == update_property:
						match prop["name"]:
							"texture":
								current_values["texture"] = new_value
							"position":
								current_values["position"] = new_value
							"centered":
								current_values["centered"] = new_value
							"padding_percent":
								current_values["padding_percent"] = new_value
							"flip_h":
								current_values["flip_h"] = new_value
							"flip_v":
								current_values["flip_v"] = new_value
							"offset":
								current_values["offset"] = new_value
							"rotation_degrees":
								current_values["rotation_degrees"] = new_value
							"z_index":
								current_values["z_index"] = new_value
			
			# Grab the texture attached to this sprite node, flipping if needed
			var sprite_texture = current_values["texture"].get_data()
			if current_values["flip_h"]:
				sprite_texture.flip_x()
			if current_values["flip_v"]:
				sprite_texture.flip_y()
			
			# Process the texture into a BitMap and generate polygons from opacity
			var bitmap = BitMap.new()
			bitmap.create_from_image_alpha(sprite_texture)
			var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()))
			
			# Invert a copy of the bitmap data to locate all transparency
			var bitmap_transparency = BitMap.new()
			bitmap_transparency.create_from_image_alpha(sprite_texture)
			for i in range(0, bitmap.get_size().y):
				for j in range(0, bitmap.get_size().x):
					bitmap_transparency.set_bit(Vector2(j, i), not bitmap_transparency.get_bit(Vector2(j, i)))
			var transparent_polygons = bitmap_transparency.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()))
			
			# Add the polygons to the CollisionPolygon2D node
			for polygon in polygons:
				var collider = CollisionPolygon2D.new()
				collider.polygon = polygon
				autocollider.add_child(collider)
			
			# TODO: Figure out how to subtract the transparency polygons from the autocollider
			
			# If the sprite is rotated, adjust the autocollider
			# TODO: Troubleshoot the rotation of the autocllider and account for the discrepancy
#			autocollider.rotation_degrees = current_values["rotation_degrees"]
			
			# If we are padding_percent the collider, do so now by scaling it
			# TODO: Determine if there is a better way to pad the autocollider
			if current_values["padding_percent"] != 100:
				# Apply scale to represent the padding
				autocollider.scale.x = current_values["padding_percent"] * 0.01
				autocollider.scale.y = current_values["padding_percent"] * 0.01
				
				# Apply any scale set to the sprite first
				# TODO: Troubleshoot scaling the autocollider in addition to the padding
#				if current_values["scale"].x != 1:
#					autocollider.scale.x += 1 - current_values["scale"].x
#				if current_values["scale"].y != 1:
#					autocollider.scale.y += 1 - current_values["scale"].y
			
			# If the autocollider was padded, scale a copy of this node and get its size
			var autocollider_size = Vector2()
			if current_values["padding_percent"] != 100:
				# Create an empty bitmap to the correct scale and get its size
				var autocollider_size_bitmap = BitMap.new()
				autocollider_size_bitmap.create(Vector2(bitmap.get_size().x * (current_values["padding_percent"] * 0.01), bitmap.get_size().y * (current_values["padding_percent"] * 0.01)))
				autocollider_size = autocollider_size_bitmap.get_size()
			else:
				autocollider_size = bitmap.get_size()

			# Align the polygon to the Sprite's exact position, depending on if its 
			# offset is set to centered
			if current_values["centered"]:
				autocollider.position.x = current_values["position"].x - (autocollider_size.x * 0.5)
				autocollider.position.y = current_values["position"].y - (autocollider_size.y * 0.5)
			else:
				autocollider.position = current_values["position"]
				# TODO: Determine how to center the autocollider over the sprite when not padded
				if current_values["padding_percent"] != 100:
					var width_difference = autocollider_size.x - bitmap.get_size().x
					var height_difference = autocollider_size.y - bitmap.get_size().y
					autocollider.position.x -= width_difference * 0.5
					autocollider.position.y -= height_difference * 0.5
			
			# Apply additional offset
			autocollider.position.x += current_values["offset"].x
			autocollider.position.y += current_values["offset"].y
			
			# Add the new autocollider to the scene tree as a sibling
			self.get_parent().add_child(autocollider)


func clear_collider(clear):
	# Clear the autocollider only if the node is not frozen
	if not self.freeze:
		var sibling_nodes = self.get_parent().get_children()
		if sibling_nodes.size() > 0:
			for node in sibling_nodes:
				if node.get_class() == "CollisionPolygon2D" and node.name == self.name + "_autocollider":
					node.get_parent().remove_child(node)


func regenerate(regenerate):
	generate_collider(true)
