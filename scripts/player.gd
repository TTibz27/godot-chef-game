extends Actor



# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const FLOOR_DETECT_DISTANCE = 20.0 
onready var platform_detector = $PlatformDetector
onready var sprite = $Sprite
onready var leftMirror = $Sprite/leftMirror
onready var rightMirror = $Sprite/rightMirror


export var  SPEED_X = 150.0
export var JUMP_STRENGTH = 300.0
var screensize_x = 1280
var mirror_pos_offset = screensize_x / 4;
var jump_direction = 0;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	leftMirror.position = Vector2 (position.x + mirror_pos_offset, position.y)
	rightMirror.position = Vector2 (position.x -320, position.y)
# THIS IS EFFECTIVELY THE ANIMATION TIMER< TIED TO FRAMERATE
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#PHYSICS TIMER
func _physics_process(_delta):
	
	screen_wrap_check()
	

	var direction = get_direction()
 
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, is_jump_interrupted)

	
	if !is_on_floor():
		apply_gravity();
		
	print(_velocity)  

	var snap = Vector2.DOWN * 16

	if  direction.y < 0:
		 snap =  Vector2.ZERO
	
	_velocity = move_and_slide_with_snap(
		_velocity, snap,  FLOOR_NORMAL, false, 4, 0.9, false
	)

	# When the character’s direction changes, we want to to scale the Sprite accordingly to flip it.
	# This will make Robi face left or right depending on the direction you move.
#	if direction.x != 0:
#		if direction.x > 0:
#			sprite.scale.x = 1
#		else:
#			sprite.scale.x = -1

	# We use the sprite's scale to store Robi’s look direction which allows us to shoot
	# bullets forward.
	# There are many situations like these where you can reuse existing properties instead of
	# creating new variables.
	# var is_shooting = false
	#if Input.is_action_just_pressed("shoot"):
#		is_shooting = gun.shoot(sprite.scale.x)

#	var animation = get_new_animation(is_shooting)
#	if animation != animation_player.current_animation and shoot_timer.is_stopped():
#		if is_shooting:
#			shoot_timer.start()
#		animation_player.play(animation)


func get_direction():
	var x_dir = 0
	if  (Input.is_action_pressed("move_left")):
		x_dir -=1
	if  (Input.is_action_pressed("move_right")):
		x_dir +=1
	if (Input.is_action_just_pressed("jump") &&  is_on_floor()):
		jump_direction = x_dir
	elif (is_on_floor()):
		jump_direction = 0
	return Vector2(
		x_dir,
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)

func calculate_move_velocity(
		linear_velocity,
		direction,
		is_jump_interrupted
	):
	var velocity = linear_velocity
	print(jump_direction)
	if is_on_floor():
		velocity.x = SPEED_X * direction.x
		
	else:
		velocity.x = (0.75 * SPEED_X * jump_direction) + (0.25 * SPEED_X * direction.x)
		if jump_direction == 0:
			velocity.x += (0.25 * SPEED_X * direction.x)
	if direction.y != 0.0:
		velocity.y = JUMP_STRENGTH * direction.y
		if 	get_floor_velocity().y > 0:
			print("ADJUSTING JUMP")
			velocity.y -= get_floor_velocity().y

	if is_jump_interrupted:
		# Decrease the Y velocity by multiplying it, but don't set it to 0
		# as to not be too abrupt.
		velocity.y *= 0.6
		
	return velocity

func screen_wrap_check():
	global_position.x = wrapf(global_position.x, 0 , screensize_x)
	#global_position.y = wrapf(global_position.y, 0 , screensize.y)
