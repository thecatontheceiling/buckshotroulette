class_name Achievement extends Node

func UnlockAchievement(apiname : String):
	Steam.setAchievement(apiname)
	Steam.storeStats()

func ClearAchievement(apiname : String):
	Steam.clearAchievement(apiname)
	Steam.storeStats()
