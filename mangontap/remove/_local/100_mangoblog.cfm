<cftry>
	<cfset plugin.getInstaller().removeFiles() />
	<cfset getIoC().detach("mangoblog") />
	<cfset plugin.setInstallationStatus(false) />
	
	<cfset htlib.childSet(tap.view.content,1,plugin.getPluginManager().goHome())>
	
	<cfcatch>
		<cfset htlib.childAdd(pluginmanager.view.error,"<p>#cfcatch.message#</p><p>#cfcatch.detail#</p>")>
	</cfcatch>
</cftry>
