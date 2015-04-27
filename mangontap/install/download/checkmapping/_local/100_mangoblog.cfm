<cf_html return="temp" parent="#pluginmanager.view.error#">
	<div xmlns:tap="xml.tapogee.com">
		<p>The system is unable to 
			<a href="<cfoutput>#plugin.getDownloadURL()#</cfoutput>" target="_blank">download Mango Blog</a> 
			to the directory 
		</p>
		
		<div><tap:variable name="installer.getInstallDirectory()" /></div>
		
		<p>You'll have to install Mango Blog manually and try again.</p>
	</div>
</cf_html>
