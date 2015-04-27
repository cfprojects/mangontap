<cfsilent>
	<!--- this tag is swapped for <mango:Blog skinurl /> 
	-- to redirect the skin files that are located outside the blog root 
	-- it is critical that this file not output any whitespace characters --->
	<cfinclude template="/cfc/mixin/tap.cfm" />
	<cfset blog = getIoC("mangoblog").getBean("blog") />
	<cfset skin = getLib().getURL("mangoblog/skins/#blog.getSkin()#/","inc") />
</cfsilent><cfoutput>#skin#</cfoutput><cfexit />