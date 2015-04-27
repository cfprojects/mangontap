<cfcomponent output="false" extends="cfc.ontap">
	<cfset variables.instance = structNew() />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="plugin" required="true" />
		<cfset structAppend(instance,arguments,true) />
		<cfreturn this />
	</cffunction>
	
	<cfset variables.sourcepath = getDirectoryFromPath(getCurrentTemplatePath())>
	
	<cffunction name="checkInstallation" access="public" output="false" returntype="boolean">
		<cfreturn fileExists(getInstallDirectory() & "/components/Mango.cfc") />
	</cffunction>
	
	<cffunction name="checkConfig" access="public" output="false" returntype="boolean">
		<cfreturn fileExists(ExpandPath("/tap/_tap/_config/mangoblog.xml.cfm")) />
	</cffunction>
	
	<cffunction name="moveConfig" access="public" output="false">
		<cfset var myFile = CreateObject("component","cfc.file").init("config.cfm",getInstallDirectory()) />
		<cfset var content = myfile.read() />
		<cfset var cfg = 0 />
		<cfset myFile.init("_config/mangoblog.xml.cfm","P").write(content) />
		<cfset cfg = createObject("component","inc.mangoblog.components.utilities.PreferencesFile").init(myFile.getValue("filepath"))>
		<cfset cfg.put("default.authorization","methods","delegated") />
		<cfset cfg.put("default.authorization.settings","component","cfc.mangoblog.authentication") />
		<cfset cfg.flush() />
	</cffunction>
	
	<cffunction name="getInstallDirectory" access="public" output="false">
		<cfreturn ExpandPath("/inc/mangoblog/") />
	</cffunction>
	
	<cffunction name="setConfigParams" access="public" output="false">
		<cfset var config = getConfig() />
		<cfset structAppend(config,arguments,true) />
		<cfset saveConfig(config) />
	</cffunction>
	
	<cffunction name="getWebAddress" access="public" output="false">
		<cfreturn getLib().getURL(getConfig().location,"T") />
	</cffunction>
	
	<cffunction name="getTruncatedWebAddress" access="public" output="false">
		<cfreturn rereplacenocase(getWebAddress(),"^https?://[^/]+/","") />
	</cffunction>
	
	<cffunction name="getFileMap" access="private" output="false">
		<cfreturn CreateObject("component","cfc.file").init("files/map.xml.cfm",variables.sourcepath,"wddx") />
	</cffunction>
	
	<cffunction name="installFiles" access="public" output="false">
		<cfset var location = getConfig().location />
		<cfset var source = variables.sourcepath />
		<cfset var map = getFileMap() />
		<cfset var x = 0 />
		<cfset var myFile = CreateObject("component","cfc.file").init("files/_tap",source) />
		
		<!--- create custom files minus cfcontent tags and layout that might interfere with integration --->
		<cfset createCustomFiles() />
		<cfset createCustomFiles("/admin") />
		
		<!--- install public files for CF7 compatibility and for webserver default documents --->
		<cfset createPublicFiles(location) />
		<cfset createPublicFiles(location,"admin") />
		
		<cfset createMapping() />
		
		<cfif not map.exists()>
			<cfset map.write(myFile.map()) />
			<cfset myFile.move("","P") />
			<cfset myFile.init("files/protected",variables.sourcepath).move(location,"P") />
		</cfif>
	</cffunction>
	
	<cffunction name="createPublicFiles" access="private" output="false">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="directory" type="string" required="false" default="" />
		<cfset var destination = getFS().getPath(location,"T") />
		<cfset var myFile = CreateObject("component","cfc.file").init(directory,getInstallDirectory()) />
		<cfset var map = myFile.read() />
		
		<cfloop query="map">
			<cfif listlast(map.name,".") is "cfm" and left(map.name,4) is not "tap_">
				<cfset myFile.init(directory & "/" & lcase(map.name),destination).write("<cfinclude template=""/tags/process.cfm"" />") />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="createCustomFiles" access="private" output="false" 
	hint="I create versions of MangoBlog files that will be compatible with the onTap framework by stripping out specific code that prevents integration">
		<cfargument name="directory" type="string" required="false" default="" />
		<cfset var destination = getInstallDirectory() & directory />
		<cfset var myFile = CreateObject("component","cfc.file").init("",destination) />
		<cfset var map = myFile.read() />
		<cfset var source = "" />
		
		<cfloop query="map">
			<cfif listlast(map.name,".") is "cfm" and left(map.name,4) is not "tap_">
				<cfset source = myFile.init(map.name,destination).read() />
				<cfset source = rereplacenocase(source,"</?cf_layout[^>]*>","","ALL") />
				<cfset source = rereplacenocase(source,"<cfcontent\sreset=""([1-9]+|yes|true)""\s*/?>","","ALL") />
				<cfset source = rereplacenocase(source,"src=""assets/editors/","src=""<cfoutput>##getLib().getURL('mangoblog/admin/','inc')##</cfoutput>/assets/editors/","ALL") />
				<cfset source = rereplacenocase(source,"(data|value)=""assets/swfs/","\1=""<cfoutput>##getLib().getURL('mangoblog/admin/','inc')##</cfoutput>/assets/swfs/","ALL") />
				<cfset source = replacenocase(source,"path=##request.blogManager.getBlog().getbasePath()##admin/com/asfusion/fileexplorer","path=<cfset temp=getFS().getPath('mangoblog','inc') />##temp##/admin/com/asfusion/fileexplorer","ALL") />
				<cfset myFile.init("tap_" & lcase(map.name),destination).write(source) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="removeFiles" access="public" output="false">
		<cfset var location = getConfig().location />
		<cfset var source = variables.sourcepath />
		<cfset var map = getFileMap() />
		<cfset var myFile = CreateObject("component","cfc.file").init("","P") />
		<cfif map.exists()>
			<cfset myFile.move("files/_tap",source,map.read()) />
			<cfset map.delete() />
		</cfif>
		<cfset myFile.init(location,"P").move("files/protected",variables.sourcepath) />
		<cfset myFile.init(location,"T").delete() />
		<cfset removeMapping() />
	</cffunction>
	
	<cffunction name="createMapping" access="private" output="false">
		<!---
			Many of Mango Blog's links unfortunately use the blog "basePath" instead of the URL 
			(both stored in the database) as their root location. Because the basePath is also used 
			as the root location for templates executed with cfinclude, this means that both of these 
			variables *MUST* match (even though they might not need to), so to resolve that issue, 
			rather than editing more of the Mango Blog files (which we're already doing quite a lot of, 
			we create an additional mapping beyond the default /org/mangoblog/ mapping and store that 
			in the database so that the path seen by cfinclude is the same as the path seen by the browser 
		--->
		<cfset var myFile = CreateObject("component","cfc.file").init("mapping.cfc",variables.sourcepath) />
		<cfset var source = replacenocase(MyFile.read(),"{MAP}",getTruncatedWebAddress()) />
		<cfset myFile.init("_config/mappings/mangoblog.cfc","p").write(source) />
	</cffunction>
	
	<cffunction name="removeMapping" access="private" output="false">
		<cfset CreateObject("component","cfc.file").init("_config/mappings/mangoblog.cfc","p").delete() />
	</cffunction>
	
	<cffunction name="getConfigFile" access="private" output="false">
		<cfreturn CreateObject("component","cfc.file").init("config.xml.cfm",variables.sourcepath,"wddx") />
	</cffunction>
	
	<cffunction name="getConfig" access="public" output="false" returntype="any">
		<cfset var myfile = getConfigFile() />
		<cfif myFile.exists()>
			<cfreturn myfile.read() />
		<cfelse>
			<cfreturn structNew() />
		</cfif>
	</cffunction>
	
	<cffunction name="cf" access="private" output="false">
		<cfargument name="string" type="string" required="true" />
		<cfset string = replace(string,'"','""','ALL') />
		<cfset string = replace(string,"##","####","ALL") />
		<cfreturn string />
	</cffunction>
	
	<cffunction name="saveConfig" access="private" output="false">
		<cfargument name="settings" type="struct" required="true" />
		<cfset getConfigFile().write(settings) />
	</cffunction>
	
	<cffunction name="deleteConfig" access="private" output="false">
		<cftry>
			<cffile action="delete" file="#variables.sourcepath#/config.cfc" />
			<cfcatch></cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getFile" access="private" output="false">
		<cfreturn getObject("file")>
	</cffunction>
	
	<cffunction name="makeDirs" access="private" output="false">
		<cfargument name="abspath" type="string" required="true" />
		
		<cfif not directoryexists(getFS().getPath(abspath,"T")) and not directoryexists(abspath)>
			<cfif left(abspath,1) is not "/" and not findnocase(":",listfirst(abspath,"\/"))>
				<cfset abspath = getFS().getPath(abspath,"T") />
			</cfif>
			
			<cfset CreateObject("java","java.io.File").init(abspath).mkdirs() />
		</cfif>
	</cffunction>
	
	<cffunction name="getArchiveFromHTTP" access="private" output="false">
		<cfset var temp = 0 />
		<cfhttp result="temp" getasbinary="yes" url="#getDownloadURL(true)#" />
		<cfreturn temp.fileContent />
	</cffunction>
	
	<cffunction name="getDownloadURL" access="public" output="false">
		<cfargument name="doit" type="boolean" required="false" default="false" />
		<cfset var href = "http://mangoblog.riaforge.org/index.cfm?event=action.download" />
		<cfif arguments.doit><cfset href = href & "&doit=true" /></cfif>
		<cfreturn href />
	</cffunction>
	
	<cffunction name="downloadLatestVersion" access="public" output="false">
		<cfset var archive = CreateObject("component","cfc.file").init("mangoblog.zip","inc","binary") />
		
		<cfif archive.exists()>
			<cfset archive.delete() />
		</cfif>
		
		<cffile action="write" file="#archive.getValue('filepath')#" output="#getArchiveFromHTTP()#" />
		<cfset archive.init("mangoblog.zip","inc","zip").extract("mangoblog") />
		<cfset archive.delete() />
	</cffunction>
	
	<cffunction name="installPermissions" access="public" output="false">
		<cfscript>
			var destination = getConfig().location; 
			setPermission(destination,"everyone","Blog","Read the blog."); 
			setPermission(destination & "/admin","admin","Admin","Manage the blog."); 
			setPermission(destination & "/admin/addons","admin","Plugins","Manage Plugins"); 
			setPermission(destination & "/admin/files","admin","Files","Manage Files"); 
			setPermission(destination & "/admin/pages","admin","Pages","Manage Pages"); 
		</cfscript>
	</cffunction>
	
	<cffunction name="removePermissions" access="public" output="false">
		<cfscript>
			var destination = getConfig().location; 
			depermission(destination); 
			depermission(destination & "/admin"); 
			depermission(destination & "/admin/addons"); 
			depermission(destination & "/admin/files"); 
			depermission(destination & "/admin/pages"); 
		</cfscript>
	</cffunction>
	
	<cffunction name="setPermission" access="private" output="false">
		<cfargument name="processpath" type="string" required="true" />
		<cfargument name="roles" type="string" required="true" />
		<cfargument name="permissionname" type="string" required="true" />
		<cfargument name="processdescription" type="string" required="true" />
		
		<cfscript>
			var policyManager = getIoC("membersontap").getBean("policymanager"); 
			var permission = policyManager.getProcessPermission(processpath); 
			var i = 0; 
			
			if (not permission.isLoaded()) { 
				permission.setProperties(arguments).update(); 
				roles = listtoarray(roles); 
				for (i = 1; i lte arraylen(roles); i = i + 1) { 
					policyManager.getRole(policyManager.getValue(roles[i])).addPermission(permission); 
				} 
			} 
		</cfscript>
	</cffunction>
	
	<cffunction name="depermission" access="private" output="false">
		<cfargument name="processpath" type="string" required="true" />
		
		<cfscript>
			var policyManager = getIoC("membersontap").getBean("policymanager"); 
			var permission = policyManager.getProcessPermission(processpath); 
			if (permission.isLoaded()) { permission.delete(); } 
		</cfscript>
	</cffunction>
</cfcomponent>
