<cf_validate form="#variables.installForm#">
	<cfset tap.goto.domain = "C" />
	<cfset tap.goto.href = structNew() />
	<cfset tap.goto.href.netaction = plugin.getValue('source') & '/install/download/checkmapping' />
	
	<cfset installer.setConfigParams(location=attributes.location) />
	
	<cftry>
		<cfset installer.downloadLatestVersion() />
		<cfcatch>
			<!--- if we can't download it, then we'll just tell the user to try downloading it manually --->
		</cfcatch>
	</cftry>
</cf_validate>