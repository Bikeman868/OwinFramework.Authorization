import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../ViewModels/AuthorizationViewModel.dart';
import '../ViewModels/RolePermissionViewModel.dart';
import '../Models/ParentChildModel.dart';
import '../Server.dart';

// Retrieves all of the role/permission assignmentd from the server
class RolePermissionListViewModel extends ViewModel
{
  ModelList<ParentChildModel, RolePermissionViewModel> rolePermissions;

	AuthorizationViewModel _authorizationViewModel;

	RolePermissionListViewModel(
		this._authorizationViewModel,
		[
			List<ParentChildModel> rolePermissionModels
		]): super(true)
	{
		rolePermissions = new ModelList<ParentChildModel, RolePermissionViewModel>(
			(Map json) => new ParentChildModel(json),
			(ParentChildModel m) => new RolePermissionViewModel(_authorizationViewModel, m));

		if (rolePermissionModels == null)
			reload();
		else
			models = rolePermissionModels;
	}

	dispose()
	{
		models = null;
	}

	List<ParentChildModel> get models
	{
		return rolePermissions.models;
	}

	void set models(List<ParentChildModel> value)
	{
		rolePermissions.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [rolePermissions];
	}

	void reload()
	{
		Server
			.getRolePermissions()
			.then((List<ParentChildModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

  Future<SaveResult> saveChanges(ChangeState state, bool alert) async
  {
    var response = await Server.updateRolePermissions(models);
    return response.isSuccess ? SaveResult.saved : SaveResult.failed;
  }

	String toString() => 'role permissions';
}

