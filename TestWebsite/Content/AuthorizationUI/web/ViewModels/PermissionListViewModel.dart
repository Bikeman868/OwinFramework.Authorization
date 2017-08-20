import '../MVVM/Mvvm.dart';
import '../ViewModels/PermissionViewModel.dart';
import '../Models/PermissionModel.dart';
import '../Server.dart';

class PermissionListViewModel extends ViewModel
{
    ModelList<PermissionModel, PermissionViewModel> permissions;

	PermissionListViewModel([List<PermissionModel> permissionModels]): super(false)
	{
		permissions = new ModelList<PermissionModel, PermissionViewModel>(
			(Map json) => new PermissionModel(null)
				..codeName = '[unique_code_name]'
				..displayName = '[display_name]'
				..description = '[description]',
			(PermissionModel m) => new PermissionViewModel(m));

		if (permissionModels == null)
			reload();
		else
			models = permissionModels;
	}

	dispose()
	{
		models = null;
	}

	List<PermissionModel> get models
	{
		return permissions.models;
	}

	void set models(List<PermissionModel> value)
	{
		permissions.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [permissions];
	}

	void reload()
	{
		Server.getPermissionList()
			.then((List<PermissionModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	String toString() => 'permission list';
}

