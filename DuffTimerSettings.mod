<?xml version="1.0" encoding="UTF-8"?>
<!--	Project: DuffTimer.	Project Author:  Thurwell	Project Date: 2009-05-09T04:47:09Z
	Project Revision: 129	Project Version: v2.2.3 
	File Author: Thurwell	File Revision: 129	File Date:	2009-05-09T04:47:09Z	-->
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<UiMod name="DuffTimerSettings" version="1.0" date="01/2009">
<Author name="Thurwell" email="" />
	<Description text="Where dufftimer saves your settings" />

	<Files>
		<File name="DuffTimerSettings.lua" />
	</Files>

	<SavedVariables>
		<SavedVariable name="DuffTimerSettings.SavedSettings" />
		<SavedVariable name="DuffTimerSettings.SkinSettings" />
		<SavedVariable name="DuffTimerSettings.FilterSettings" />
	</SavedVariables>
	<OnShutdown>
		<CallFunction name="DuffTimerSettings.OnShutdown" />
	</OnShutdown>


</UiMod>
</ModuleFile>
