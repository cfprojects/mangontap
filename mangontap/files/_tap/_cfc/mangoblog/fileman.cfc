<cfcomponent displayname="MangoBlog.FileMan" output="false" 
hint="URLs for pages in the blog should be case insensitive, but we're using cfinclude to get them here, so we need to make sure the cfinclude is also case insensitive on linux/unix servers">
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cfset variables.instance = structNew() />
	<cfset instance.iCanRematch = structKeyExists(getFunctionList(),"rematch") />
	
	<cffunction name="init" access="public" output="false">
		<cfset instance.skin = getBlog().getSkin() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getBlog" access="private" output="false">
		<cfreturn getIoC("mangoblog").getBean("blog") />
	</cffunction>
	
	<cffunction name="getSkin" access="private" output="false">
		<cfreturn instance.skin />
	</cffunction>
	
	<cffunction name="isAdminPage" access="private" output="false" returntype="boolean">
		<cfargument name="abspath" type="string" required="true" />
		<cfreturn iif(listlast(getDirectoryFromPath(abspath),"\/") is "admin",true,false) />
	</cffunction>
	
	<cffunction name="MyREMatch" access="private" output="false" returntype="array" 
	hint="performs a rematch() or equivalent if the function isn't available">
		<cfargument name="expression" type="string" required="true" />
		<cfargument name="string" type="string" required="true" />
		<cfset var result = "" />
		<cfset var i = 0 />
		
		<cfif instance.iCanREMatch>
			<cfreturn rematchnocase(expression,string) />
		<cfelse>
			<cfset result = refindnocase(expression,string,1,true) />
			<cfloop index="i" from="1" to="#ArrayLen(result.pos)#">
				<cfset result.pos[i] = mid(string,result.pos[i],result.len[i]) />
			</cfloop>
			<cfset result = result.pos />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="setRequestTemplate" access="public" output="false" 
	hint="Tells Mango Blog what template to include for the page from the skin directory -- modifies the template if needed">
		<cfargument name="template" type="string" required="true" />
		<cfargument name="admin" type="boolean" required="false" default="false" />
		<cfset var crlf = chr(13) & chr(10) />
		<cfset var my = structNew() />
		
		<cfif refindnocase("^tap_",arguments.template)>
			<cfreturn arguments.template />
		</cfif>
		
		<cfset my.skin = getSkin() />
		<cfset my.template = "tap_" & lcase(arguments.template) />
		<cfset my.destination = ExpandPath("/inc/mangoblog/skins/" & my.skin) />
		
		<cfif arguments.admin>
			<cfreturn my.template />
		</cfif>
		
		<cfif not fileExists(my.destination & "/" & my.template)>
			<cffile action="read" variable="my.source" file="#my.destination#/#arguments.template#" />
			
			<!--- remove the doctype from the skin --->
			<cfset my.source = rereplacenocase(my.source,"<!DOCTYPE[^>]+>","") />
			
			<!--- cut the head off - we need to preserve certain tags from the skin that are improperly nested --->
			<cfset my.head = rereplacenocase(my.source,"^.*<head[^>]*>(.*)</head>.*$","\1") />
			<cfset my.tags = myREMatch("<mango(:author|:page|:post|x:\w+)(?!property)[^>]*>",my.head) />
			<cfset my.source = rereplacenocase(my.source,"<head[^>]*>.*</head>","") />
			<cfset my.source = rereplace(my.source,"(<body[^>]*>)","\1" & crlf & ArrayToList(my.tags,crlf)) />
			
			<!--- reset the url for any assets like images that might come from the skin --->
			<cfset my.source = rereplacenocase(my.source,"<mango:Blog skinurl[^>]*>","<tapskin />","ALL") />
			
			<!--- add code to remove the display of html, head and body tags --->
			<cfset my.source = "<cfimport prefix="""" taglib=""/tags/mangoblog/"">" & crlf & my.source />
			
			<cffile action="write" output="#my.source#" file="#my.destination#/#my.template#" />
		</cfif>
		
		<cfset request[listfirst(arguments.template,".") & "Template"] = my.template />
		
		<cfreturn my.template />
	</cffunction>
	
	<cffunction name="getIncludeFile" access="public" output="false" returntype="string">
		<cfargument name="abspath" type="string" required="false" default="#getBaseTemplatePath()#" />
		<cfscript>
			var admin = isAdminPage(abspath); 
			var template = getFileFromPath(abspath); 
			return "/inc/mangoblog/" & iif(admin,de("admin/"),de("")) & setRequestTemplate(template,admin); 
		</cfscript>
	</cffunction>
	
	<cffunction name="getAdminPage" access="public" output="false" 
	hint="Mango Blog's admin area needs to know what page is being called, but it's not always the same as the base template name">
		<cfargument name="abspath" type="string" required="false" default="#getBaseTemplatePath()#" />
		<cfscript>
			var page = rereplacenocase(getFileFromPath(abspath),"\.cfm$",""); 
			
			switch (page) { 
				case "index": { page = "Overview"; break; } 
				case "generic": { 
					if (isDefined("url.selected") 
					and listfirst(url.selected,"-") is "PodManager") 
						{ page = "Pod Manager"; } 
					else { page = "Links"; } 
					break; 
				} 
			} 
			
			return page; 
		</cfscript>
	</cffunction>
</cfcomponent>