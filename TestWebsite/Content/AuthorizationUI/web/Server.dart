import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'Models/ApiResponseModel.dart';
import 'Models/NewRecordResponseModel.dart';
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
		String responseString = await HttpRequest.getString(_apiUrl + '/permissions');
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) return null;

		List<Map> permissionsJson = responseJson['permissions'];

		var permissions = new List<PermissionModel>();
		for (Map permissionJson in permissionsJson)
		{
			permissions.add(new PermissionModel(permissionJson));
		}
		return permissions;
	}

	static Future<ApiResponseModel> validatePermission(PermissionModel permission) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/validate/permission', 
			method: 'POST',
			sendData: JSON.encode(permission.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to validate permission ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}
  
	static Future<ApiResponseModel> createPermission(PermissionModel permission) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/permissions', 
			method: 'POST',
			sendData: JSON.encode(permission.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to create permission ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new NewRecordResponseModel(json);
	}
  
	static Future<ApiResponseModel> updatePermission(PermissionModel permission) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/permission/' + permission.id.toString(), 
			method: 'PUT',
			sendData: JSON.encode(permission.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to update permission ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}
  
	static Future<ApiResponseModel> deletePermission(PermissionModel permission) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/permission/' + permission.id.toString(), 
			method: 'DELETE',
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to delete permission ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}

//
//-- Role related server methods -----------------------------------------------------------------
//
	static Future<List<RoleModel>> getRoleList() async
	{
		String responseString = await HttpRequest.getString(_apiUrl + '/roles');
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) return null;

		List<Map> rolesJson = responseJson['roles'];

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
		String responseString = await HttpRequest.getString(_apiUrl + '/groups');
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) return null;

		List<Map> groupsJson = responseJson['groups'];

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
		String responseString = await HttpRequest.getString(_apiUrl + '/identity/_search?q=' + searchText);
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) return null;

		List<Map> identitiesJson = responseJson['identities'];

		var identities = new List<IdentityModel>();
		for (Map identityJson in identitiesJson)
		{
			identities.add(new IdentityModel(identityJson));
		}
		return identities;
	}

}