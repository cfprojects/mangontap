<cfcomponent displayname="MangoBlog.PluginLoader" extends="inc.mangoblog.components.PluginLoader" output="false">
	
	<!--- we only had to create this version of the pluginloader because of methods with "package" access --->
	
	<cffunction name="loadPlugins" access="public" output="false" returntype="Any">
		<cfargument name="list" type="any" required="true" />
		<cfargument name="pluginQueue" type="PluginQueue" required="true" />
		<cfargument name="path" type="string" required="false" default="#ExpandPath('/inc/mangoblog/components/')#" />
		<cfargument name="componentBasePath" type="string" required="false" default="" />
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
		<cfreturn super.loadPlugins(argumentcollection=arguments) />
	</cffunction>
	
	<cffunction name="loadPlugin" access="public" output="false" returntype="void">
		<cfargument name="pluginData" type="struct" required="true" />
		<cfargument name="pluginQueue" type="PluginQueue" required="true" />
		<cfargument name="componentBasePath" type="string" required="false" default="" />
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
		<cfset super.loadPlugin(argumentcollection=arguments) />
	</cffunction>
	
</cfcomponent>