<cfset minversion = 3.3>
<cfset minbuild = 20091012>
<cfif not plugin.checkDependency("ontapframework",minversion,minbuild)>
	<!--- need a new version of the onTap framework --->
	<cf_html parent="#pluginmanager.view.error#">
		<div xmlns:tap="xml.tapogee.com">
			<p>This version of the <tap:text><tap:variable name="plugin.getValue('name')" /></tap:text> 
			requires version <tap:variable name="minversion" /> 
			build number <tap:variable name="minbuild" /> or later of the onTap framework.</p>
			
			<p><tap:text>Download the latest version at </tap:text>
			<a href="http://on.tapogee.com" /></p>
		</div>
	</cf_html>
	
	<cfinclude template="/inc/pluginmanager/view.cfm" />
	<cf_abort />
<cfelseif not plugin.checkDependency("membersontap",minversion,minbuild)>
	<!--- need a new version of the Members onTap plugin --->
	<cfset variables.getfrom = "" />
	<cftry>
		<cfset temp = pluginAgent.findPlugin("membersontap") />
		<cfset variables.getfrom = temp[1] />
		<cfcatch></cfcatch>
	</cftry>
	
	<cf_html parent="#pluginmanager.view.error#">
		<div xmlns:tap="xml.tapogee.com">
			<p>This version of <tap:text><tap:variable name="plugin.getValue('name')" /></tap:text> 
			requires version <tap:variable name="minversion" /> 
			build number <tap:variable name="minbuild" /> 
			or later of the Members onTap plugin.</p>
			
			<cfif len(getfrom)>
				<p>Install the latest version from the 
				<a href="get.cfm?pluginid=membersontap">
					<tap:url name="serviceuri" value="variables.getfrom" />
					webservice
				</a>.</p>
				
				<p>OR</p>
			</cfif>
			
			<p>Get the latest version from <a href="http://membersontap.riaforge.org">RIAForge</a>.</p>
		</div>
	</cf_html>
	
	<cfinclude template="/inc/pluginmanager/view.cfm" />
	<cf_abort />
<cfelse>
	<!--- using an unsupported database platform --->
	<cfset datasource = getIoC("membersontap").getBean("datasource") />
	
	<cfif not listfindnocase("mssql,mysql",datasource.getValue("server"))>
		<cf_html parent="#pluginmanager.view.error#">
			<div xmlns:tap="xml.tapogee.com">
				<p>This version of <tap:text><tap:variable name="plugin.getValue('name')" /></tap:text> 
				works with MySQL and MS SQL Server 2005. You will need to reinstall the 
				Members onTap plugin with one of those databases and try again.</p>
				
				<p><tap:text>Download the latest version at </tap:text>
				<a href="http://on.tapogee.com" /></p>
			</div>
		</cf_html>
		
		<cfinclude template="/inc/pluginmanager/view.cfm" />
		<cf_abort />
	</cfif>
</cfif>

<!--- this was added because we were having some problems with enablecfoutputonly 
preventing the Mango Blog setup.cfc from creating its XML config file 
--  not sure how we got doubled-up on the enablecfoutputonly setting, but this 
tag will absolutely disable it, no matter how many times it's been set 
(which is wierd behavior for cfsetting, but that's how it behaves) --->
<cf_outputonly enable="false" />

<cfset installer = plugin.getInstaller() />
