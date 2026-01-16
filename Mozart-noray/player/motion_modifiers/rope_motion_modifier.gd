class_name RopeMotionModifier
extends MotionModifier

var rope_anchor : DynamicAnchor

func modify_motion(v : Vector2) -> Vector2:
	if is_instance_valid(rope_anchor) and active:
		return rope_anchor.modify_motion(v)
	else:
		return v
