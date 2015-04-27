<cfparam name="attributes.email" type="string" default="#getTap().session.getValue('memberemail')#" />
<cfparam name="attributes.email_wordpress" type="string" default="#attributes.email#" />
<cfparam name="attributes.name" type="string" default="#getTap().session.getValue('preferredFamiliarName')#" />

<cfparam name="attributes.isblognew" type="string" default="yes" />
<cfif not listfindnocase("yes,no",attributes.isblognew)>
	<cfset attributes.isblognew = "yes" />
</cfif>

<cf_html return="temp" parent="#pluginmanager.view.main#">
	<div xmlns:tap="xml.tapogee.com" class="formwrapper">
	<form method="post" action="?" enctype="multipart/form-data" tap:variable="installform">
		<input type="hidden" name="netaction" value="<cfoutput>#plugin.getValue('source')#</cfoutput>/install/configure/complete" />
		<p>
			<strong>Is this blog new?</strong>
			<span class="field">
				<label class="option"><input type="radio" name="isblognew" value="yes" class="required switch group-a activate-a" /> Yes</label>
				<label class="option"><input type="radio" name="isblognew" value="no" class="required switch group-a activate-b" /> No, I want to import data from another blog</label>
			</span>
		</p>
		
		<!--- <fieldset class="switched group-a active-a">
			<legend>Author Information</legend>
			<p>
				<label for="name">Name</label>
				<span class="field"><input type="text" id="name" name="name" value="" size="30" class="required" tap:required="true" /></span>
			</p>
			
			<p>
				<label for="email">Email</label>
				<span class="hint">Email address where password will be sent if forgotten. This address also identifies the author when writing comments in posts.</span>
				<span class="field"><input type="text" id="email" name="email" size="50" class="email required" tap:required="true" /></span>
			</p>
		</fieldset> --->
		
		<fieldset class="switched group-a active-a">
			<legend>Blog Information</legend>
			<p>
				<label for="blog_title">Title</label>
				<span class="field"><input type="text" id="blog_title" name="blog_title" size="50" class="required" tap:default="My Mango Blog" tap:required="true" /></span>
			</p>
		</fieldset>
		
		<fieldset class="switched group-a active-b">
			<legend>Blog Import</legend>
			<p>
				<strong>Blog engine</strong>
				<span class="field">
				<label class="option"><input type="radio" value="wordpress" name="blogengine" class="required switch group-b activate-c" /> Wordpress</label>
				<label class="option"><input type="radio" value="BlogCFC" name="blogengine" class="required switch group-b activate-d" /> BlogCFC 5.x</label>
				</span>
			</p>
			
			<div class="switched group-b active-c">
				<p>
					To export Wordpress content, go to your Wordpress admin, click Manage &gt; Import. Save the file to your computer.
				</p>
			
				<p>
					<label for="datafile_wordpress">Exported data file</label>
					<span class="hint">File that you saved with Wordpress content</span>
					<span class="field"><input type="file" id="datafile_wordpress" name="datafile_wordpress" value="" class="required"/></span>
				</p>	
				
				<p>
					<label for="email_wordpress">Email address</label>
					<span class="hint">Main address to use when sending email</span>
					<span class="field"><input type="text" id="email_wordpress" name="email_wordpress" size="50" class="email required"/></span>
				</p>
			</div>
			
			<div class="switched group-b active-d">
				<p>
					<label for="blogcfcini">Configuration file</label>
					<span class="hint">Full path of the location of your blog.ini.cfm file (e.g. c:\inetpub\wwwroot\myblog\blog.ini.cfm)</span>
					<span class="field"><input type="text" id="blogcfcini" name="blogcfcini" size="50" class="required"/></span>
				</p>
			</div>
		</fieldset>
		
		<div style="text-align:center">
			<button type="submit">Finish</button>
		</div>
	</form>
	</div>
</cf_html>
