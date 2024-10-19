extends CharacterBody2D

@export
var p_state: PlayerState

@export
var m_move_speed := 250.0

var p_repel_cooldown: Timer

## The player's unscaled velocity
var m_velocity: Vector2

@onready
var p_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready
var p_vfx: GPUParticles2D = $RepelEffect


#region Events

func _ready() -> void:
	p_repel_cooldown = Timer.new()
	p_repel_cooldown.wait_time = 0.5
	p_repel_cooldown.one_shot = true

	add_child.call_deferred(p_repel_cooldown)


func _unhandled_key_input(event: InputEvent) -> void:
	if !event.is_action_pressed(&"repel") || !p_repel_cooldown.is_stopped():
		return

	p_state.repel_nearby()

	p_sprite.scale.y = randf_range(1.5, 3.0)
	var tween := create_tween()

	tween.tween_property(p_sprite, ^"scale:y", 1.0, 0.33) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)

	p_vfx.restart()
	p_repel_cooldown.start()


func _process(_delta: float) -> void:
	__handle_input()


func _physics_process(_delta: float) -> void:
	velocity = m_velocity * m_move_speed
	move_and_slide()

	p_state.m_position = global_position


#region Input

func __handle_input() -> void:
	var input := Input.get_vector(&"left", &"right", &"up", &"down")

	if input.is_zero_approx():
		m_velocity = m_velocity.lerp(Vector2.ZERO, 0.1)
		p_sprite.play(&"default")
		return

	m_velocity = m_velocity.lerp(input, 0.2)

	p_sprite.play(&"walk")
	p_sprite.flip_h = m_velocity.x < 0.0
