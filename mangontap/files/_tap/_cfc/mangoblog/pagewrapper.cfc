<cfcomponent displayname="MangoBlog.PageWrapper" extends="inc.mangoblog.components.pagewrapper" 
hint="This is a wrapper for Page objects. It has the same interface as the normal Page, but does other things such as calling plugins">
	<cfinclude template="/cfc/mixin/tap.cfm" />
	
	<cffunction name="getTemplate" output="false" access="public" returntype="any">
		<cfreturn getIoC("mangoblog").getBean("fileman").setRequestTemplate(super.getTemplate()) />
	</cffunction>

</cfcomponent>