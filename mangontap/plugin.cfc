<cfcomponent output="false" extends="cfc.plugin">
	<cfset setValue("name","Mango Blog Plugin")>
	<cfset setValue("version","1.0")>
	<cfset setValue("revision","beta")>
	<cfset setValue("releasedate","28-Oct-2009")>
	<cfset setValue("buildnumber",dateformat(getValue("releasedate"),"yyyymmdd"))>
	<cfset setValue("description","Installs Mango Blog into your onTap framework application.")>
	<cfset setValue("providerName","Projects onTap")>
	<cfset setValue("providerEmail","info@tapogee.com")>
	<cfset setValue("providerURL","http://on.tapogee.com")>
	<cfset setValue("install","install/license")>
	<cfset setValue("configure","install/configure")>
	<cfset setValue("remove","remove")>
	<cfset setValue("docs","mangoblog")>
	
	<cfset variables.sourcepath = getDirectoryFromPath(getCurrentTemplatePath())>
	
	<cffunction name="getConfig" access="public" output="false">
		<cfreturn getInstaller().getConfig() />
	</cffunction>
	
	<cffunction name="getInstaller" access="public" output="false">
		<cfif not structKeyExists(variables,"installer")>
			<cfset variables.installer = CreateObject("component","installer").init(this) />
		</cfif>
		<cfreturn variables.installer />
	</cffunction>
	
</cfcomponent>
