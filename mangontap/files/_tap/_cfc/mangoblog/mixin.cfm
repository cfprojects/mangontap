<cfinclude template="/cfc/mixin/tap.cfm">

<cffunction name="tapGetObject" access="private" output="false">
	<cfargument name="className" type="string" required="true" />
	<cfif fileExists(ExpandPath("/cfc/mangoblog/#lcase(className)#.cfc"))>
		<cfset className = lcase(className) />
	<cfelse>
		<cfset className = "inc.mangoblog.components." & className />
	</cfif>
	<cfreturn CreateObject("component",className) />
</cffunction>

<cffunction name="getTapConfig" access="private" output="false">
	<cfreturn CreateObject("component","cfc.file").init("source/mangontap/config.xml.cfm","plugins","wddx").read() />
</cffunction>
