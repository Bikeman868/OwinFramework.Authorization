import '../MVVM/Mvvm.dart';
import '../ViewModels/RolePermissionViewModel.dart';
import '../ViewModels/RoleListViewModel.dart';
import '../ViewModels/PermissionListViewModel.dart';
import '../Models/ParentChildModel.dart';
import '../Server.dart';

class RolePermissionListViewModel extends ViewModel
{
    ModelList<ParentChildModel, RolePermissionViewModel> rolePermissions;

	RoleListViewModel _roleListViewModel;
	PermissionListViewModel _permissionListViewModel;

	RolePermissionListViewModel(
		this._roleListViewModel,
		this._permissionListViewModel,
		[
			List<ParentChildModel> rolePermissionModels
		]): super(false)
	{
		rolePermissions = new ModelList<ParentChildModel, RolePermissionViewModel>(
			(Map json) => new ParentChildModel(json),
			(ParentChildModel m) => new RolePermissionViewModel(_roleListViewModel, _permissionListViewModel, m));

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
		Server.getRolePermissions()
			.then((List<ParentChildModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	String toString() => 'role permissions';
}

