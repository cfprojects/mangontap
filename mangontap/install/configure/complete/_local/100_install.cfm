<cf_validate form="#variables.installForm#">
	<cfset error = "" />
	
	<cfset structAppend(attributes,installer.getConfig()) />
	<cfset member = getTap().session.getMember() />
	
	<cftry>
		<cfif installer.checkConfig()>
			<cfset qBlog = DataSource.getSelect("a.blog_id, a.author_id",attributes.prefix & "blog b").filter("b.id","default","=") />
			<cfset qBlog.join(attributes.prefix & "author_blog a",true,"blog_id","id").filter("role","administrator","=") />
			<cfset qBlog = qBlog.execute() />
			
			<cfif qBlog.recordcount>
				<cfset temp = structNew() />
				<cfset temp.id = qBlog.blog_id />
				<cfset temp.blog_title = attributes.blog_title />
				<cfset DataSource.update(attributes.prefix & "blog",temp) />
				<cfthrow type="skip" message="A-Okay" />
			</cfif>
		</cfif>
		
		<cfset setupObj = CreateObject("component", "inc.mangoblog.admin.setup.Setup").init(installer.getWebAddress(),datasource.getValue("datasource"), attributes.dbType, attributes.prefix, datasource.getValue("usr"), datasource.getValue("pwd"))/>
		<cfset path = installer.getInstallDirectory() & "/" />
		
		<!--- new blog --->
		<cfif attributes.isblognew>
			<cfset result = setupObj.saveConfig(path,'','',email)/>
			
			<cfif result.status>
				<cfset result = setupObj.addBlog(attributes.blog_title, installer.getWebAddress())/>
				
				<cfif result.status>
					<cfset result = setupObj.addAuthor(member.getValue("preferredfamiliarname"), member.getValue("memberusername"), "dummy", member.getValue("memberemail")) />
					<cfif result.status>
						<cfset result = setupObj.addData() />
					</cfif>
					
					<cfif NOT result.status>
						<cfset error = result.message />
					<cfelse>
						<cfset step = 3 />
						<cfset setupObj.setupPlugins() />
					</cfif>					
				<cfelse>
					<cfset error = result.message />
				</cfif>
			<cfelse>
				<cfset error = result.message />
			</cfif>
		
		<cfelseif NOT attributes.isblognew>
		<!--- import --->
			<cfswitch expression="#attributes.blogengine#">
		
			<!--- wordpress --->
		
			<cfcase value="blogCFC">
				<!--- blogCFC --->
				<cftry>
					<div class="message">
						<cfset importObj = CreateObject("component", "Importer_BlogCFC_5x").init(installer.getWebAddress(),path,attributes.blogcfcini,datasource.getValue("datasource"), attributes.dbType, attributes.prefix, datasource.getValue("usr"), datasource.getValue("pwd"))/>
						<cfset result = importObj.import(installer.getWebAddress()) />
					</div>
					<cfif NOT result.status>
						<cfset error = result.message />
					<cfelse>
						<cfset setupObj.setupPlugins() />
						<cfset step = 3/>
					</cfif>
					<cfcatch type="any">
						</div>
						<cfset error = cfcatch.message & ": " & cfcatch.detail />
					</cfcatch>
				</cftry>
			</cfcase>
	
			<cfcase value="wordpress">
				<!--- Upload exported file --->
				<cftry>
					<cffile action="upload" destination="#expandPath('.')#" filefield="datafile_wordpress" nameconflict="overwrite">
					<cfif cffile.fileWasSaved>
						
						<cftry>
							<div class="message">
								<cfset importObj = CreateObject("component", "Importer_Wordpress").init(installer.getWebAddress(),path,cffile.ServerDirectory & "/" & CFFILE.ServerFile,
										datasource.getValue("datasource"), attributes.dbType, attributes.prefix,pluginspath, datasource.getValue("usr"), datasource.getValue("pwd"))/>
								<cfset result = importObj.import(installer.getWebAddress(), attributes.email_wordpress) />
								
							</div>
							<cfif NOT result.status>
								<cfset error = result.message />
							<cfelse>
								<cfset setupObj.setupPlugins() />
								<cfset step = 3/>
							</cfif>
							<cfcatch type="any">
								</div>
								<cfset error = cfcatch.message & ": " & cfcatch.detail />
							</cfcatch>
						</cftry>
						
					<cfelse>
						<cfset error = "File could not be saved">	
					</cfif>
					<cfcatch type="any">
						<cfset error = cfcatch.message & ": " & cfcatch.detail />
					</cfcatch>
				</cftry>
				
			</cfcase>
			</cfswitch>
		<cfelse>
			<cfset error = result.message />
		</cfif>
		
		<cfif len(trim(error))>
			<cfthrow type="application" message="#error#" />
		<cfelse>
			<cfthrow type="skip" message="A-Okay" />
		</cfif>
		
		<cfcatch type="skip">
			<!--- move the config file to our framework config directory --->
			<cfif not installer.checkConfig()>
				<cfset installer.moveConfig() />
			</cfif>
			
			<!--- add the blog and blog admin to the Members onTap permission system --->
			<cfset installer.installPermissions() />
			
			<!--- make sure the blog has the correct path information for our custom version --->
			<cfset temp = structNew() />
			<cfset temp.id = "default" />
			<cfset temp.basePath = "/#installer.getTruncatedWebAddress()#/" />
			<cfset DataSource.update(attributes.prefix & "blog",temp) />
			
			<!--- attach the blog IoC Container and announce a successful installation --->
			<cfset getIoC().newContainer("mangoblog").init("cfc.mangoblog.iocfactory","tap_mango") />
			<cfset application.blogFacade = getIoC("mangoblog").getFactory() />
			
			<cfset plugin.setInstallationStatus(true) />
			
			<cfset htlib.childSet(pluginmanager.view.main,1,plugin.getPluginManager().goHome()) />
		</cfcatch>
		
		<cfcatch>
			<cfset htlib.childAdd(pluginManager.view.error,"<p>#cfcatch.message#</p><p>#cfcatch.detail#</p>") />
		</cfcatch>
	</cftry>
</cf_validate>
