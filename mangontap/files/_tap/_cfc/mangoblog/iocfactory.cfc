<cfcomponent displayname="MangoBlog.IoCFactory" extends="cfc.ioc.iocfactory" output="false">
	<cfscript>
		// bean definitions go here 
		define("mango","cfc.mangoblog.mango"); 
		define("fileman","cfc.mangoblog.fileman"); // this file is necessary to make the base templates case-insensitive on linux/unix because we're using cfinclude to import content here 
		define("application","cfc.mangoblog.application"); // we use the original Mangoblog application.cfc for the onRequestStart() method 
		define("authentication","cfc.mangoblog.authentication"); // this object integrates Mango Blog with the Members onTap user / security system 
		define("authorizer"); // this is the Mango Blog Authorizer object that's responsible for setting up native Mango Blog user records in the db and handling login 
		define("blog"); 
	</cfscript>
	
	<cffunction name="getCached_blog" access="private" output="false">
		<cfreturn getBean("Mango").getBlog() />
	</cffunction>
	
	<cffunction name="getCached_authorizer" access="private" output="false">
		<cfreturn getBean("Mango").getAuthorizer() />
	</cffunction>
	
	<cffunction name="getMango" access="public" output="false" returntype="Mango">
		<cfreturn getBean("mango") />
	</cffunction>
	
	<cffunction name="setMango" access="public" output="false" returntype="void">
		<cfargument name="mango" type="Mango" required="true" />		
		<cfset var storage = getProperty("storage") />
		<cfset var result = structNew() />
		<cfset result.status = 1 />
		
		<cfloop condition="result.status">
			<cfset storage.expire("mango") />
			<cfset result = storage.store("mango",arguments.mango) />
		</cfloop>
	</cffunction>
</cfcomponent>
