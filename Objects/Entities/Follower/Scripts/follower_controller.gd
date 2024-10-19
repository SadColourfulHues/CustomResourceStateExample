extends CharacterBody2D

signal unalived()

## Squared distance constants
const MIN_DISTANCE := 450.0 * 450.0
const STOP_DISTANCE := 64.0 * 64.0
const REPEL_DISTANCE := 120.0 * 120.0

@export
var p_player_state: PlayerState

@export
var m_move_speed = 180.0

var m_health := 3

var m_extra_forces: Vector2
var m_velocity: Vector2

@onready
var p_sprite: AnimatedSprite2D = $AnimatedSprite2D


#region Events

func _enter_tree() -> void:
    p_player_state.repel_requested.connect(_on_repel)


func _exit_tree() -> void:
    # Always disconnect when it's no longer being used, just to be safe
    p_player_state.repel_requested.disconnect(_on_repel)


func _physics_process(_delta: float) -> void:
    __handle_behaviour()

    velocity = (m_velocity * m_move_speed) + m_extra_forces
    m_extra_forces = m_extra_forces.lerp(Vector2.ZERO, 0.125)
    move_and_slide()


func _on_repel(source: Vector2) -> void:
    # Active test
    if !is_physics_processing():
        return

    var current_position := global_position

    # Too far to be repelled
    if current_position.distance_squared_to(source) > REPEL_DISTANCE:
        return

    m_extra_forces += source.direction_to(current_position) * 1500.0
    m_health -= 1

    # RIP
    if m_health > 1:
        return

    # Stop processing
    set_physics_process(false)

    # Animate out
    var tween := create_tween()

    tween.parallel().tween_property(self, ^"rotation", TAU, 0.25)

    tween.tween_property(self, ^"modulate:a", 0.0, 0.35) \
        .set_trans(Tween.TRANS_SINE) \
        .set_ease(Tween.EASE_OUT)

    tween.tween_callback((func():
        unalived.emit()
        queue_free()
    ))


#region Utils

func __handle_behaviour() -> void:
    var current_position := global_position
    var distance := current_position.distance_squared_to(p_player_state.m_position)

    # Player is either too far away or too close
    if distance >= MIN_DISTANCE || distance <= STOP_DISTANCE:
        m_velocity = lerp(m_velocity, Vector2.ZERO, 0.1)
        p_sprite.play(&"default")
        return

    # Chase
    m_velocity = lerp(m_velocity, current_position.direction_to(p_player_state.m_position), 0.185)

    p_sprite.play(&"walk")
    p_sprite.flip_h = m_velocity.x < 0.0