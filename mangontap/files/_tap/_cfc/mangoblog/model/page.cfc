<cfcomponent displayname="MangoBlog.model.Page" extends="inc.mangoblog.components.model.Page" output="false">
	
	<cffunction name="getTemplate" access="public" output="false">
		<cfreturn getIoC("mangoblog").getBean("fileman").setRequestTemplate(super.getTemplate()) />
	</cffunction>
	
</cfcomponent>