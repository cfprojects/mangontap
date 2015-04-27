<cfcomponent displayname="MangoBlog.Mango" output="false" extends="inc.mangoblog.components.Mango">
	<cfinclude template="mixin.cfm" />
	
	<cffunction name="init" access="public" output="false">
		<cfset var settings = "" />
		<cfset var preferences = tapGetObject("utilities.PreferencesFile") />
		<cfset var pluginDir = ExpandPath("/inc/mangoblog/components/") />
		<cfset var pluginPath = "inc.mangoblog.components.plugins." />
		
		<cfset variables.config = getFS().getPath("_config/mangoblog.xml.cfm","p") />
		<cfset variables.blogId = "default" />
		<cfset variables.settings["baseDirectory"] = ExpandPath("/inc/mangoblog/") />
		
		<!--- check for the config file --->
		<cfif fileexists(variables.config)>
			<cfset preferences.init(variables.config)/>
		<cfelse>
			<cfthrow type="MissingConfigFile" errorcode="MissingConfigFile" detail="Configuration file could not be read">
		</cfif>
		
		<cfset settings = preferences.exportSubtreeAsStruct("") />
		
		<cfif settings.generalSettings.system.enableThreads EQ "1">
			<cfset variables.pluginQueue = tapGetObject("PluginQueueThreaded")/>
		<cfelse>
			<cfset variables.pluginQueue = tapGetObject("PluginQueue")/>
		</cfif>
		
	 	<cfscript>
		 	if (len(settings[variables.blogId].plugins.directory)){
				pluginDir = replaceDirectoryPlaceHolders(settings[variables.blogId].plugins.directory);
				pluginPath = settings[variables.blogId].plugins.path;
			}
			//replace the {baseDirectory} variable
		 	settings[variables.blogId].blogSettings.admin.customPanels.directory = 
		 		replaceDirectoryPlaceHolders(settings[variables.blogId].blogSettings.admin.customPanels.directory);
		 		
		 	settings[variables.blogId].blogSettings.assets.directory = 
		 		replaceDirectoryPlaceHolders(settings[variables.blogId].blogSettings.assets.directory);
		 		
		 	settings[variables.blogId].blogSettings.skinsDirectory = 
		 		replaceDirectoryPlaceHolders(settings[variables.blogId].blogSettings.skinsDirectory);
		 											
		 	variables.objectFactory = tapGetObject("ObjectFactory");
		 	variables.settings["mailServer"] = settings.generalSettings.mailServer;
		 	variables.settings["datasource"] = settings.generalSettings.dataSource;
		 	variables.settings["authorization"] = settings[variables.blogId].authorization;
		 	variables.dataAccessFactory = tapGetObject("model.dataaccess.DataAccessFactory").init(variables.settings["dataSource"]);		
	 		variables.blogManager = tapGetObject("BlogManager").init(this);
			variables.blog = variables.blogManager.getBlog(variables.blogId,settings[variables.blogId].blogSettings);		
			variables.blog.setSetting("pluginsDir", pluginDir);
			variables.blog.setSetting("pluginsPath", pluginPath);
			variables.blog.setSetting("pluginsPrefsPath", "");
			
			variables.postsManager = tapGetObject("PostManager").init(this);
			variables.categoriesManager = tapGetObject("CategoryManager").init(this);
			variables.rolesManager = tapGetObject("RoleManager").init(this,variables.dataAccessFactory,variables.pluginQueue);
			variables.archivesManager = tapGetObject("ArchivesManager").init(this,variables.dataAccessFactory);
			variables.authorsManager = tapGetObject("AuthorManager").init(this);
			variables.pagesManager = tapGetObject("PageManager").init(this);
			variables.commentsManager = tapGetObject("CommentManager").init(this,variables.dataAccessFactory,variables.pluginQueue);
			
			try {
				variables.searcher = tapGetObject(settings[variables.blogId].searchSettings.component).init(
								settings[variables.blogId].searchSettings.settings,
								settings[variables.blogId].blogSettings.language,
								variables.blogId);
			}
			catch (var e) {}
			
			variables.preferences["plugins"] = tapGetObject("SettingManager").init(this, variables.dataAccessFactory);
		</cfscript>
		
		<cfset loadPlugins(pluginDir,pluginPath, variables.isAdmin) />
		
		<cfreturn this />
	</cffunction>
	
	<!--- we needed to override this to give it public instead of package access --->
	<cffunction name="getDataAccessFactory" access="public" output="false" returntype="any">		
		<cfreturn variables.dataAccessFactory />
	</cffunction>
	
	<!--- we only had to add these two methods because of "package" access in the plugin loader 
	-- and no encapsulation of CreateObject() in the original Mango.cfc --->
	<cffunction name="loadPlugins" access="private" output="false" returntype="void">
		<cfargument name="pluginsDir" type="String" required="true" />
		<cfargument name="pluginsPath" type="String" required="false" default="plugins." />
		<cfargument name="isAdmin" required="false" default="false" type="boolean" hint="Whether this Mango instantiation is administration or the blog"/>
		
		<cfset tapGetObject("PluginLoader").loadPlugins(variables.blog.systemPlugins,variables.pluginQueue,
					arguments.pluginsDir & "system/",arguments.pluginsPath & "system." , this, variables.preferences["plugins"]) />
		<cfset tapGetObject("PluginLoader").loadPlugins(variables.blog.plugins,variables.pluginQueue,
					arguments.pluginsDir & "user/", arguments.pluginsPath & "user.", this, variables.preferences["plugins"]) />
	
	</cffunction>
	
	<cffunction name="loadPlugin" access="public" output="false" returntype="string" hint="returns the name of the plugin if successfully loaded">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="type" type="string" required="false" default="user" />
		
		<cfreturn tapGetObject("PluginLoader").loadPlugins(plugin,variables.pluginQueue,
					variables.blog.getSetting("pluginsDir") & arguments.type & "/",
					variables.blog.getSetting("pluginsPath") & arguments.type & "." , 
					this, variables.preferences["plugins"]) />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="replaceDirectoryPlaceHolders" access="private">
		<cfargument name="data" type="string" />
		
		<cfset arguments.data = replacenocase(arguments.data,"{baseDirectory}",variables.settings["baseDirectory"]) />
		<cfreturn replacenocase(arguments.data,"{componentsDirectory}",ExpandPath("/inc/mangoblog/components/")) />
	</cffunction>
</cfcomponent>