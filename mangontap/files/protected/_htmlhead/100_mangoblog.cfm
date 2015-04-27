<cfif listlast(getDirectoryFromPath(getBaseTemplatePath()),"/\") is not "admin">
	<cfimport prefix="mango" taglib="/inc/mangoblog/tags/mango">
	
	<cfoutput>
		<cfsavecontent variable="temp"><mango:Blog atomurl /></cfsavecontent>
		<link rel="alternate" type="application/atom+xml" title="Atom" href="#trim(temp)#" />
		
		<cfsavecontent variable="temp"><mango:Blog rssurl /></cfsavecontent>
		<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="#trim(temp)#" />
		
		<cfsavecontent variable="temp"><mango:Blog apiurl /></cfsavecontent>
		<link rel="EditURI" type="application/rsd+xml" title="RSD" href="#trim(temp)#" />
		
		<cfsavecontent variable="temp"><mango:Blog skinurl /></cfsavecontent>
		<cfset temp = getTap().getPath().getURL(ExpandPath(trim(temp))) />
		<link rel="stylesheet" type="text/css" href="#temp#assets/styles/style.css" media="screen" />
		<link rel="stylesheet" type="text/css" href="#temp#assets/styles/print.css" media="print" />
		<link rel="stylesheet" type="text/css" href="#temp#assets/styles/custom.css" media="screen" />
		<!--[if lte IE 7]>
		<link rel="stylesheet" type="text/css" href="#temp#assets/styles/ie7.css" media="screen" />
		<![endif]-->
		<!--[if lte IE 6]>
		<link rel="stylesheet" type="text/css" href="#temp#assets/styles/ie6.css" media="screen" />
		<![endif]-->
		<mango:Event name="beforeHtmlHeadEnd" />
	</cfoutput>
</cfif>
