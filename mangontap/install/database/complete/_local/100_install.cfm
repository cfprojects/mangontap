<cf_validate form="#variables.installForm#">
	<cftry>
		<cfset htlib = getLib().html />
		
		<cfset installer.setConfigParams(dbtype=attributes.dbtype, prefix=attributes.prefix) />
		
		<cfset setupObj = CreateObject("component", "inc.mangoblog.admin.setup.Setup") />
		<!--- use the Members onTap plugin datasource --->
		<cfset setupObj.init(installer.getWebAddress(), datasource.getValue("datasource"), 
				attributes.dbType, attributes.prefix, datasource.getValue("usr"), datasource.getValue("pwd")) />
		<cfset result = setupObj.setupDatabase() />
		
		<cfif result.status>
			<cfset tap.goto.domain = "C" />
			<cfset tap.goto.href = structNew() />
			<cfset tap.goto.href.netaction = plugin.getValue('source') & '/install/configure' />
		<cfelse>
			<cfthrow type="application" message="#result.message#" />
		</cfif>
		
		<cfcatch>
			<cfset htlib.childAdd(pluginManager.view.error,"<p>#cfcatch.message#</p><p>#cfcatch.detail#</p>") />
		</cfcatch>
	</cftry>
</cf_validate>
