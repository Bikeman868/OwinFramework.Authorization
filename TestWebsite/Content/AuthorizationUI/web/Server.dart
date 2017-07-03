import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'Models/GroupModel.dart';
import 'Models/PermissionModel.dart';
import 'Models/RoleModel.dart';
import 'Models/IdentityModel.dart';

class Server
{

	static String _apiUrl = '/api/authorization';
//
//-- Permission related server methods -----------------------------------------------------------------
//
	static Future<List<PermissionModel>> getPermissionList() async
	{
		String response = await HttpRequest.getString(_apiUrl + '/permissions');
		Map responseJson = JSON.decode(response);

		List<Map> permissionsJson = responseJson['permissions'];

		var permissions = new List<PermissionModel>();
		for (Map permissionJson in permissionsJson)
		{
			permissions.add(new PermissionModel(permissionJson));
		}
		return permissions;
	}

//
//-- Role related server methods -----------------------------------------------------------------
//
	static Future<List<RoleModel>> getRoleList() async
	{
		String response = await HttpRequest.getString(_apiUrl + '/roles');
		List<Map> rolesJson = JSON.decode(response);

		var roles = new List<RoleModel>();
		for (Map roleJson in rolesJson)
		{
			roles.add(new RoleModel(roleJson));
		}
		return roles;
	}

//
//-- Group related server methods -----------------------------------------------------------------
//
	static Future<List<GroupModel>> getGroupList() async
	{
		String response = await HttpRequest.getString(_apiUrl + '/groups');
		List<Map> groupsJson = JSON.decode(response);

		var groups = new List<GroupModel>();
		for (Map groupJson in groupsJson)
		{
			groups.add(new GroupModel(groupJson));
		}
		return groups;
	}

//
//-- Identity related server methods -----------------------------------------------------------------
//
	static Future<List<IdentityModel>> findIdentities(String searchText) async
	{
		String response = await HttpRequest.getString(_apiUrl + '/identities/_search?q=' + searchText);
		List<Map> identitiesJson = JSON.decode(response);

		var identities = new List<IdentityModel>();
		for (Map identityJson in identities)
		{
			identities.add(new IdentityModel(identityJson));
		}
		return identities;
	}

}