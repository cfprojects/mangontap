<cfcomponent extends="config" hint="configure the MangoBlog DI Factory">
	
	<cffunction name="configure" access="public" output="false" returntype="void">
		<cfset newContainer("mangoblog").init("cfc.mangoblog.iocfactory","tap_mango") />
		
		<!--- this application scope reference looks bad, but it only *looks* bad 
		-- the fact that MangoBlog used this Facade object at all saved us HUGE headaches 
		integrating it into the application framework, making it immeasurably easier to integrate 
		compared to other applications such as BlogCFC which is littered with references to 
		application.this and application.that throughout the view code -- although I do wish 
		it were application.mango instead of application.blogFacade --->
		<cfif isDefined("application")>
			<cfset application.blogFacade = getContainer("mangoblog").getFactory() />
		</cfif>
	</cffunction>
	
</cfcomponent>
