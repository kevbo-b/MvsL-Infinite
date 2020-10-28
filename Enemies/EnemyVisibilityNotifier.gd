extends VisibilityNotifier2D

func _ready():
	pass # Replace with function body.
	
var lookingViewports = 0;

#Currently not in use. Consider to re-use with Online-Mode

func _on_EnemyVisibilityNotifier_viewport_entered(viewport):
	#lookingViewports += 1;
	#get_parent().setIsOnScreen(true);
	pass

func _on_EnemyVisibilityNotifier_viewport_exited(viewport):
	#lookingViewports -= 1;
	#if(lookingViewports == 0):
	#	get_parent().setIsOnScreen(false);
	pass
