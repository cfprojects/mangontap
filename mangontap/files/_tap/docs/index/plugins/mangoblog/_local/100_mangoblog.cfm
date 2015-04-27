<cfset plugin = getIoC().getBean("mangontap","plugins") />

<cfoutput>
	<cfsavecontent variable="tap.view.content">
	#htlib.show(docPage(plugin.getValue("name") & " " 
		& plugin.getValue("version") & " " & plugin.getValue("revision")))#
	
	<p>Mango Blog is a stand-alone blog application for ColdFusion. The Mango Blog 
	Plugin allows you to run Mango Blog within the context of an onTap framework application.</p>
	
	<p>For more information about Mango Blog, visit the official website at:
	<a href="http://www.mangoblog.org" /></p>
	
	</cfsavecontent>
</cfoutput>
