import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'MVVM/Mvvm.dart';

import 'Models/ApiResponseModel.dart';
import 'Models/NewRecordResponseModel.dart';
import 'Models/NewIdentityResponseModel.dart';
import 'Models/GroupModel.dart';
import 'Models/PermissionModel.dart';
import 'Models/RoleModel.dart';
import 'Models/IdentityModel.dart';
import 'Models/ParentChildModel.dart';
import 'Models/ConfigurationModel.dart';

class Server
{

	static String _apiUrl = '{_api-url_}';

	static Initialize()
	{
		InputElement apiUrl = querySelector('#api-url');
		if (apiUrl != null)
			_apiUrl = apiUrl.value;
	}

	static void reportForbidden(String action)
	{
		MvvmEvents.alert.raise(
			'You do not have permission to ' + action + 
			'.\nCheck that you logged into the correct account.');
	}

	static void reportServerError(String action)
	{
		MvvmEvents.alert.raise(
			'The back-end service encountered a critical error whilst trying to ' + action + '.' +
			'.\nPlease inform the system administrator about this issue.');
	}

	static void reportFailedResponse(String action, ApiResponseModel response)
	{
			MvvmEvents.alert.raise(
				'Failed to ' + action + '.\n' + 
				response.result + ' - ' + response.error);
	}

	static void handleError(HttpRequest request, String action)
	{
		print(request.responseUrl + ' => ' + request.statusText);

		if (request.status == 403) reportForbidden(action);
		else if (request.status == 500) reportServerError(action);
	}

//
//-- Configuration related server methods -----------------------------------------------------------------
//

static Future<ConfigurationModel> getConfiguration() async
{
		String action = 'retrieve configuration data';

		return HttpRequest
			.getString(_apiUrl + '/configuration')

			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					reportFailedResponse(action, response);
					return null;
				}

				Map configurationJson = responseJson['configuration'];
				return new ConfigurationModel(configurationJson);
			})

			.catchError((e) => handleError(e.target, action));
}

//
//-- Permission related server methods -----------------------------------------------------------------
//
	static Future<List<PermissionModel>> getPermissionList() async
	{
		String action = 'retrieve a list of permissions';

		return HttpRequest
			.getString(_apiUrl + '/permissions')

			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					reportFailedResponse(action, response);
					return null;
				}

				List<Map> permissionsJson = responseJson['permissions'];

				var permissions = new List<PermissionModel>();
				for (Map permissionJson in permissionsJson)
				{
					permissions.add(new PermissionModel(permissionJson));
				}
				return permissions;
			})

			.catchError((e) => handleError(e.target, action));
	}

	static Future<PermissionModel> getPermission(int permissionId) async
	{
		String action = 'retrieve permission ' + permissionId.toString();

		return HttpRequest.getString(_apiUrl + '/permission/' + permissionId.toString())

			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					reportFailedResponse(action, response);
					return null;
				}

				Map permissionJson = responseJson['permission'];
				return new PermissionModel(permissionJson);
			})

			.catchError((e) => handleError(e.target, action));
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
  
	static Future<NewRecordResponseModel> createPermission(PermissionModel permission) async
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
		String action = 'retrieve a list of roles ';

		return HttpRequest.getString(_apiUrl + '/roles')

			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					reportFailedResponse(action, response);
					return null;
				}

				List<Map> rolesJson = responseJson['roles'];

				var roles = new List<RoleModel>();
				for (Map roleJson in rolesJson)
				{
					roles.add(new RoleModel(roleJson));
				}
				return roles;
			})

			.catchError((e) => handleError(e.target, action));
	}

	static Future<RoleModel> getRole(int roleId) async
	{
		String action = 'retrieve role ' + roleId.toString();

		return HttpRequest.getString(_apiUrl + '/role/' + roleId.toString())

			.then((responseString)
			{
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
			})

			.catchError((e) => handleError(e.target, action));
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
  
	static Future<NewRecordResponseModel> createRole(RoleModel role) async
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
		String action = 'retrieve a list of groups';

		return HttpRequest.getString(_apiUrl + '/groups')

			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					reportFailedResponse(action, response);
					return null;
				}

				List<Map> groupsJson = responseJson['groups'];

				var groups = new List<GroupModel>();
				for (Map groupJson in groupsJson)
				{
					groups.add(new GroupModel(groupJson));
				}
				return groups;
			})

			.catchError((e) => handleError(e.target, action));
	}

	static Future<GroupModel> getGroup(int groupId) async
	{
		String action = 'retrieve group ' + groupId.toString();

		return HttpRequest.getString(_apiUrl + '/group/' + groupId.toString())

			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					reportFailedResponse(action, response);
					return null;
				}

				Map groupJson = responseJson['group'];
				return new GroupModel(groupJson);
			})

			.catchError((e) => handleError(e.target, action));
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
  
	static Future<NewRecordResponseModel> createGroup(GroupModel group) async
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
		String action = 'search for identities matching "' + searchText + '"';

		return HttpRequest.getString(_apiUrl + '/identity/_search?q=' + searchText)

			.then((responseString)
			{
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
			})

			.catchError((e) => handleError(e.target, action));
	}

	static Future<IdentityModel> getIdentity(String identity) async
	{
		String action = 'retrieve identity ' + identity;

		return HttpRequest.getString(_apiUrl + '/identity?identity=' + identity)
			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					reportFailedResponse(action, response);
					return null;
				}

				Map identityJson = responseJson['identity'];
				return new IdentityModel(identityJson);
			})

			.catchError((e) => handleError(e.target, action));
	}

	static Future<NewIdentityResponseModel> createIdentity(IdentityModel identity) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/identities', 
			method: 'POST',
			sendData: JSON.encode(identity.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to create identity ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new NewIdentityResponseModel(json);
	}
  
	static Future<ApiResponseModel> updateIdentity(IdentityModel identity) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/identity/' + identity.identity.toString(), 
			method: 'PUT',
			sendData: JSON.encode(identity.json),
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to update identity ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}

	static Future<ApiResponseModel> deleteIdentity(String identity) async
	{
		var request = await HttpRequest.request(
			_apiUrl + '/identity/' + identity, 
			method: 'DELETE',
			mimeType: 'application/json');

		if (request.status != 200)
			throw 'Failed to delete identity ' + request.statusText;

		Map json = JSON.decode(request.responseText);
		return new ApiResponseModel(json);
	}

//
//-- Many-to-many relationships -----------------------------------------------------------------
//

	static Future<List<ParentChildModel>> getGroupRoles() async
	{
		String action = 'retrieve group/roles';

		return HttpRequest.getString(_apiUrl + '/group/roles')

			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					reportFailedResponse(action, response);
					return null;
				}

				List<Map> relationsJson = responseJson['relations'];

				var relations = new List<ParentChildModel>();
				for (Map relationJson in relationsJson)
				{
					relations.add(new ParentChildModel(relationJson));
				}
				return relations;
			})

			.catchError((e) => handleError(e.target, action));
	}

	static Future<List<ParentChildModel>> getRolePermissions() async
	{
		String action = 'retrieve role/permissions';

		return HttpRequest.getString(_apiUrl + '/role/permissions')

			.then((responseString)
			{
				Map responseJson = JSON.decode(responseString);

				var response = new ApiResponseModel(responseJson);
				if (!response.isSuccess) 
				{
					MvvmEvents.alert.raise(
						'Failed to retrieve the list of role-permission assignments. ' + 
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
			})

			.catchError((e) => handleError(e.target, action));
	}
}
