import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'MVVM/Events.dart';

import 'Models/ApiResponseModel.dart';
import 'Models/NewRecordResponseModel.dart';
import 'Models/GroupModel.dart';
import 'Models/PermissionModel.dart';
import 'Models/RoleModel.dart';
import 'Models/IdentityModel.dart';
import 'Models/ParentChildModel.dart';

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
		if (!response.isSuccess) 
		{
			MvvmEvents.alert.raise(
				'Failed to retrieve a list of permissions. ' + 
				response.result + ' - ' + response.error);
			return null;
		}

		List<Map> permissionsJson = responseJson['permissions'];

		var permissions = new List<PermissionModel>();
		for (Map permissionJson in permissionsJson)
		{
			permissions.add(new PermissionModel(permissionJson));
		}
		return permissions;
	}

	static Future<PermissionModel> getPermission(int permissionId) async
	{
		String responseString = await HttpRequest.getString(_apiUrl + '/permission/' + permissionId.toString());
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) 
		{
			MvvmEvents.alert.raise(
				'Failed to retrieve permission. ' + 
				response.result + ' - ' + response.error);
			return null;
		}

		Map permissionJson = responseJson['permission'];
		return new PermissionModel(permissionJson);
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
  
	static Future<ApiResponseModel> deletePermission(int permissionId) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/permission/' + permissionId.toString(), 
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
		if (!response.isSuccess) 
		{
			MvvmEvents.alert.raise(
				'Failed to retrieve the list of roles. ' + 
				response.result + ' - ' + response.error);
			return null;
		}

		List<Map> rolesJson = responseJson['roles'];

		var roles = new List<RoleModel>();
		for (Map roleJson in rolesJson)
		{
			roles.add(new RoleModel(roleJson));
		}
		return roles;
	}

	static Future<RoleModel> getRole(int roleId) async
	{
		String responseString = await HttpRequest.getString(_apiUrl + '/role/' + roleId.toString());
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) 
		{
			MvvmEvents.alert.raise(
				'Failed to retrieve the role. ' + 
				response.result + ' - ' + response.error);
			return null;
		}

		Map roleJson = responseJson['role'];
		return new RoleModel(roleJson);
	}

	static Future<ApiResponseModel> validateRole(RoleModel role) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/validate/role', 
			method: 'POST',
			sendData: JSON.encode(role.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to validate role ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}
  
	static Future<ApiResponseModel> createRole(RoleModel role) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/roles', 
			method: 'POST',
			sendData: JSON.encode(role.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to create role ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new NewRecordResponseModel(json);
	}
  
	static Future<ApiResponseModel> updateRole(RoleModel role) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/role/' + role.id.toString(), 
			method: 'PUT',
			sendData: JSON.encode(role.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to update role ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}
  
	static Future<ApiResponseModel> deleteRole(int roleId) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/role/' + roleId.toString(), 
			method: 'DELETE',
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to delete role ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}

//
//-- Group related server methods -----------------------------------------------------------------
//
	static Future<List<GroupModel>> getGroupList() async
	{
		String responseString = await HttpRequest.getString(_apiUrl + '/groups');
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) 
		{
			MvvmEvents.alert.raise(
				'Failed to retrieve the list of groups. ' + 
				response.result + ' - ' + response.error);
			return null;
		}

		List<Map> groupsJson = responseJson['groups'];

		var groups = new List<GroupModel>();
		for (Map groupJson in groupsJson)
		{
			groups.add(new GroupModel(groupJson));
		}
		return groups;
	}

	static Future<GroupModel> getGroup(int groupId) async
	{
		String responseString = await HttpRequest.getString(_apiUrl + '/group/' + groupId.toString());
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) 
		{
			MvvmEvents.alert.raise(
				'Failed to retrieve the group. ' + 
				response.result + ' - ' + response.error);
			return null;
		}

		Map groupJson = responseJson['group'];
		return new GroupModel(groupJson);
	}

	static Future<ApiResponseModel> validateGroup(GroupModel group) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/validate/group', 
			method: 'POST',
			sendData: JSON.encode(group.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to validate group ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}
  
	static Future<ApiResponseModel> createGroup(GroupModel group) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/groups', 
			method: 'POST',
			sendData: JSON.encode(group.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to create group ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new NewRecordResponseModel(json);
	}
  
	static Future<ApiResponseModel> updateGroup(GroupModel group) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/group/' + group.id.toString(), 
			method: 'PUT',
			sendData: JSON.encode(group.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to update group ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}
  
	static Future<ApiResponseModel> deleteGroup(int groupId, int replacementGroup) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/group/' + groupId.toString() + '?replacement=' + replacementGroup.toString(), 
			method: 'DELETE',
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to delete group ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
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

//
//-- Many-to-many relationships -----------------------------------------------------------------
//
	static Future<List<ParentChildModel>> getGroupRoles() async
	{
		String responseString = await HttpRequest.getString(_apiUrl + '/group/roles');
		Map responseJson = JSON.decode(responseString);

		var response = new ApiResponseModel(responseJson);
		if (!response.isSuccess) 
		{
			MvvmEvents.alert.raise(
				'Failed to retrieve the list of group-role assignments. ' + 
				response.result + ' - ' + response.error);
			return null;
		}

		List<Map> relationsJson = responseJson['relations'];

		var relations = new List<ParentChildModel>();
		for (Map relationJson in relationsJson)
		{
			relations.add(new ParentChildModel(relationJson));
		}
		return relations;
	}

}
