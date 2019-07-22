if not DuffTimer then DuffTimer={} end
if not DuffTimerSettings then DuffTimerSettings={} end
	
function DuffTimerSettings.OnShutdown()
	if DuffTimer.SavedSettings then DuffTimerSettings.SavedSettings = DuffTimer.SavedSettings end
	if Duffskin and  Duffskin.GetInitialized() then 
		DuffTimerSettings.SkinSettings = Duffskin.SavedSettings 
	else
		DuffTimerSettings.SkinSettings = false
	end
	if DuffFilter and  DuffFilter.GetInitialized() then 
		DuffTimerSettings.FilterSettings = DuffFilter.SavedSettings 
	else
		DuffTimerSettings.FilterSettings = false
	end
end