extends Node

var p = 1;

func _input(event):
	if event.is_action_pressed("change_pallete"):
		if p == 1:
			$Pallete1.hide();
			p = 2
			$Pallete2.show();
		elif p == 2:
			$Pallete2.hide()
			p = 3
			$Pallete3.show();
		elif p == 3:
			$Pallete3.hide()
			p = 1
			$Pallete1.show();
