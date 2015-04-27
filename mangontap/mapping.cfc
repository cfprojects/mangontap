<cfcomponent extends="config">
	
	<cffunction name="configure" access="public" output="false">
		<cfset addMapping("org/mangoblog",getFilePath("mangoblog/components","inc"),false) />
		<cfset addMapping("{MAP}",getFilePath("mangoblog","inc"),false) />
	</cffunction>
</cfcomponent>
