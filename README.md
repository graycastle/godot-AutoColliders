# AutoColliders for Godot
A plugin for the Godot game engine that enables the automatic creation of colliders on nodes. This will initially focus on colliders for CollisionPolygon2D nodes, but is intended to be expanded to also enable collider generation for 3D meshes.

![Preview of an automatically generated sprite collider](https://www.lukeamiller.net/wp-content/uploads/2022/05/godot-autocolliders-preview.png)

## Disclaimer
This plugin is still in very early development, so feel free to give it a whirl with the knowledge that there are likely still bugs and inefficiencies.

Also, as of the time of initial publishing, I've been using Godot for all of about a week, so go gentle on me for any issues in code formatting 🤣

## Installation
Simply download the addons/autocolliders directory and ensure it's added to your project in the exact same format. It should live in your project at `res://addons/autocollider` if done successfully.

Then, simply go to Project -> Project Settings -> Plugins and enable it.

Once done, you should now have the **AutoColliderSprite** node available to add to your scene tree, which can be used and treated largely the same as any other Sprite node.

## Usage
Upon adding your AutoColliderSprite to your scene tree, you can add a texture and make changes to many of the properties to see the automatically generated CollisionPolygon2D sibling update in real time. If you would like the collider to be larger or smaller than the actual sprite, change the `padding_percent` property to scale it to a percentage of the size of the sprite. **Note:** This scaling works well on symmetrical sprites, though sprites that have multiple parts or are off-center may see issues with padding. This is a known issue, and is accounted for in the roadmap below.

If you would like to prevent any changes or updates to the collider, simply check the **Freeze** option on the node. This will lock the colliders in their current state and prevent any changes.

To handle most issues in the collider not refreshing (if not frozen), choose Clear and then Regenerate. Clear will delete the collider entirely, and Regenerate will both clear and rebuild the collider from scratch.

Generally, the automated changes to the collider are locked to only work in the editor environment to prevent unforeseen runtime frame-by-frame collider regeneration and impacts to performance (which, at this early version, haven't even seen to be an issue yet). However, you can call the `clear_collider()` functionon the node, passing in a boolean of `true` as the only parameter, and then the `generate_collider()` function on the node to execute the regeneration, again passing in `true` as the only parameter. This *should* allow for on the fly regeneration of the collider in realtime. I'll likely be smoothing this process out in a future update into a single function call.

## Roadmap
This plugin is, again, in very early development, but I do have some changes and enhancements in mind. Check the roadmap below to see what's been done so far, and what is still planned.

- [x] Enable basic 2D sprite collider generation
- [x] Enable automatic regeneration of collider on changes to sprite
- [ ] Address issues with handling of `rotation_degrees` and `scale` on the sprite in applying them to the collider
- [ ] Investigate better ways to implement padding the autocollider around the bounds of the sprite texture
- [ ] Investigate the subtraction of interior transparent sections from the final autocollider, allowing for holes with no collision
- [ ] Expand the plugin to also handle automatic generation of colliders for 3D meshes
