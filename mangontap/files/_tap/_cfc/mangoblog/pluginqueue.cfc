<cfcomponent displayname="MangoBlog.PluginQueue" extends="inc.mangoblog.components.PluginQueue" output="false">
	<!--- we need this because the plugin loader has arguments of type "PluginQueue" --->
	<cfinclude template="mixin.cfm" />
	
	<cffunction name="tapGetLogger" access="private" output="false">
		<cfreturn tapGetObject("utilities.Logger") />
	</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="addListener" access="public" output="false" returntype="boolean">
		<cfargument name="plugin" type="any" required="true" /><!--- type any just because we are not using mappings, so we cannot extend from Plugin --->
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventType" type="string" required="false" default="synch" hint="synch/asynch" />
		<cfargument name="priority" type="any" required="false" default="5" />
		
			<cfset var pluginContainer = structnew() />
			<cfset pluginContainer.plugin = arguments.plugin />
			<cfset pluginContainer.eventType = arguments.eventType />
			
			<cfset variables.plugins[arguments.plugin.getId()] = arguments.plugin />
			
			
			<!--- check to see if we already have a queue for this event name --->
			<cfif NOT structkeyexists(variables.queues,arguments.eventName)>
				<cfset variables.queues[arguments.eventName] = tapGetObject("utilities.Queue") />
			</cfif>
			
			<cfset variables.queues[arguments.eventName].addElement(pluginContainer,arguments.priority) />	
				
		<cfreturn true />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="broadcastEvent" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var allPlugins = "" />
			<cfset var thisPlugin = "" />
			<cfset var i = "" />
			<cfset var eventName = arguments.event.name />
			<cfset var logger = ""/>
			
			<cfif structkeyexists(variables.queues,eventName)>
				<cfset allPlugins = variables.queues[eventName].getElements() />
				
				<cfloop from="1" to="#arraylen(allPlugins)#" index="i">
					<cfset thisPlugin = allPlugins[i].plugin />
					<cfif allPlugins[i].eventType EQ "synch">
						<cftry>
							<cfset arguments.event = thisPlugin.processEvent(arguments.event) />
							<cfcatch type="any">
								<!--- if plugin fails, silently continue --->
								<cfset logger = tapGetLogger() />
								<cfset logger.logObject("error",cfcatch,  "Error while calling plugin") />
							</cfcatch>
						</cftry>
						
						<cfif NOT arguments.event.continueProcess>
							<cfbreak>
						</cfif>
					<cfelseif allPlugins[i].eventType EQ "asynch">
						<cftry>
							<cfset thisPlugin.handleEvent(arguments.event) />
						<cfcatch type="any">
							<!--- if plugin fails, silently continue --->
							<cfset logger = tapGetLogger() />
							<cfset logger.logObject("error",cfcatch,  "Error while calling plugin") />
						</cfcatch>
						</cftry>
						
					</cfif>
					
				</cfloop>
				
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="createEvent" access="public" output="false" hint="Factory method for creating events" returntype="any">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="data" type="any" required="false" default="#structnew()#" />
		<cfargument name="type" type="string" required="false" default="" />
		
		<cfreturn tapGetObject("events.#arguments.type#Event").init(name,arguments.data) />
	</cffunction>
	
</cfcomponent>
