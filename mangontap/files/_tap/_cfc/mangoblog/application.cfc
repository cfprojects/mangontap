<cfcomponent displayname="MangoBlog.Application" output="false" extends="inc.mangoblog.Application">
	<cfinclude template="/cfc/mixin/tap.cfm" />
	<cfset variables.componentPath = "inc.mangoblog.components." />
	
	<cffunction name="init" access="public" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="onRequestStart" access="public" output="false">
		<cfargument name="targetPage" type="string" required="true" />
		<cfset var outonly = 0 />
		<cf_outputonly enable="false" return="outonly" />
		
		<cfset getCurrentUser() />
		<cfset super.onRequestStart(targetPage) />
		
		<cfif outonly>
			<cf_outputonly enable="true" repeat="#outonly#" />
		</cfif>
	</cffunction>
	
	<cffunction name="isAdminRequest" access="private">
		<cfargument name="path" type="string" />
		<cfargument name="basepath" type="string" />
		
		<cfreturn iif(listlast(getDirectoryFromPath(arguments.path),"\/") is "admin",true,false) />
	</cffunction>
	
	<cffunction name="getCurrentUser" access="private" output="false">
		<cftry>
			<!--- we need to make sure that the current logged-in user is loaded into the Mango Blog system 
			-- we do that by checking to see if the mango blog user exists and if not then we load it with 
			-- data from our member session object --->
			<cfset getIoC("mangoblog").getBean("mango").getCurrentUser() />
			<cfcatch type="NotLoggedIn">
				<cfif getTap().session.isIdentified()>
					<cfset getIoC("mangoblog").getBean("authentication").loadSessionCredentials() />
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>
	
</cfcomponent>