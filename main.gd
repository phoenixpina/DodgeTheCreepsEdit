extends Node

@export var mob_scene: PackedScene
var score

func _ready():
	pass

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	$Music.play()

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	
	#This is what I am editing: Varying mob size spawning.
	var random_scale = randf_range(0.3, 1.8)  # Random scale between 0.5x and 1.5x
	mob.scale = Vector2(random_scale, random_scale)  # Applies the scale uniformly
	var collision_shape = mob.get_node("CollisionShape2D") # Adjusts the collision shape's scale
	if collision_shape: 
		var shape = collision_shape.shape
		if shape is CapsuleShape2D:
			shape.radius *= random_scale
			shape.height *= random_scale
	
	var sprite = mob.get_node("AnimatedSprite2D") #Adjusts animation sprite so it matches collision box
	if sprite:
		sprite.scale = Vector2(random_scale, random_scale) 

	#Code from tutorial begins again here
	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
