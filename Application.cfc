/**
* 
* This file is part of MuraGoogleCalendar
*
* Copyright 2013-2018 Stephen J. Withington, Jr.
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
component accessors=true output=false {

	property name='$';

	this.pluginName = 'MuraGoogleCalendar';

	include '../../core/appcfc/applicationSettings.cfm';
	include '../mappings.cfm';

	public any function onApplicationStart() {
		include '../../core/appcfc/onApplicationStart_include.cfm';
		var $ = get$();
		return true;
	}

	public any function onRequestStart(required string targetPage) {
		var $ = get$();
		include '../../core/appcfc/onRequestStart_include.cfm';
		if ( StructKeyExists(url, $.globalConfig('appreloadkey')) ) {
			onApplicationStart();
		}
		secureRequest();
		return true;
	}

	public void function onRequest(required string targetPage) {
		var $ = get$();
		var pluginConfig = $.getPlugin(this.pluginName);
		include arguments.targetPage;
	}


	// ----------------------------------------------------------------------
	// HELPERS

	public struct function get$() {
		return IsDefined('session') && StructKeyExists(session, 'siteid') ?
				application.serviceFactory.getBean('$').init(session.siteid) :
				application.serviceFactory.getBean('$').init('default');
	}

	public any function secureRequest() {
		var $ = get$();
		return !inPluginDirectory() || $.currentUser().isSuperUser() ? true :
			( inPluginDirectory() && !structKeyExists(session, 'siteid') ) ||
			( inPluginDirectory() && !$.getBean('permUtility').getModulePerm($.getPlugin(this.pluginName).getModuleID(),session.siteid) )
				? goToLogin() : true;
	}

	public boolean function inPluginDirectory() {
		return ListFindNoCase(getPageContext().getRequest().getRequestURI(), 'plugins', '/');
	}

	private void function goToLogin() {
		var $ = get$();
		location(url='#$.globalConfig('context')#/admin/index.cfm?muraAction=clogin.main&returnURL=#$.globalConfig('context')#/plugins/#$.getPlugin(this.pluginName).getPackage()#/', addtoken=false);
	}

}