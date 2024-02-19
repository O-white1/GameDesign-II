extends CharacterBody3D
@onready var dmg_area = $DamgageArea
@onready var atk_area = $AttackArea
@onready var nav_agent = $NavigationAgent3D

var SPEED = 3.0
var ACCEL = 20.0

func physics_process(delta):
	for player in get_tree().get_nodes_on_group("Player"):
		if $AttackRange.overlaps_body(player):
			nav_agent.target_position = player.global_position
		# TODO: player DMG
	var dir = (nav_agent.target_position - self.global_position).normalized()
	velocity = velocity.lerp(dir * SPEED, ACCEL * delta)
	move_and_slide()
