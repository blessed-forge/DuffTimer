<?xml version="1.0" encoding="UTF-8"?>
<!--	Project: DuffTimer.	Project Author:  Thurwell	Project Date: 2009-05-09T04:47:09Z
	Project Revision: 129	Project Version: v2.2.3 
	File Author: Thurwell	File Revision: 129	File Date:	2009-05-09T04:47:09Z	-->
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

<!--@non-debug@-->
<UiMod name="DuffTimer" version="v2.2.3" date="2009-05-09T04:47:09Z">
<Author name="Thurwell" email="" />
<!--@end-non-debug@-->
 
<!--@debug@
 <UiMod name="DuffTimer" version="Debug" date="01/2009">
<Author name="Thurwell" email="" />
 @end-debug@-->

	<Description text="Buff/debuff timers for player, offensive and defensive targets" />

	<Dependencies>
		<Dependency name="DuffTimerSettings" />
		<Dependency name="EASystem_LayoutEditor" />
		<Dependency name="EA_SettingsWindow" />
	</Dependencies>

	<Files>
		<File name="LibSharedAssets/LibStub.lua" />
		<File name="LibSharedAssets/LibSharedAssets.lua" />
		<File name="LibSharedAssets/textures/textures.lua" />
		<File name="LibSharedAssets/textures/textures.xml" />
		<File name="DuffTimerLanguage.lua" />
		<File name="DuffTimer.xml" />
		<File name="DuffTimerOptionsDefn.xml" />
		<File name="DuffTimerOptions.xml" />
		<File name="DuffTimerDefaultOptions.lua" />
		<File name="DuffTimerOptions.lua" />
		<File name="DuffTimer.lua" />
	</Files>
	
	<SavedVariables>
		<SavedVariable name="DuffTimer.SavedSettings" />
	</SavedVariables>
	
	<OnInitialize>
		<CallFunction name="DuffTimer.OnInitialize" />
	</OnInitialize>
	
	<OnShutdown>
		<CallFunction name="DuffTimer.OnShutdown" />
	</OnShutdown>

</UiMod>
</ModuleFile>
