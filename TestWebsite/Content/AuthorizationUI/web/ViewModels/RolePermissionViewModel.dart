import '../MVVM/Mvvm.dart';
import '../ViewModels/PermissionListViewModel.dart';
import '../ViewModels/RoleListViewModel.dart';
import '../ViewModels/PermissionViewModel.dart';
import '../ViewModels/RoleViewModel.dart';
import '../Models/ParentChildModel.dart';

class RolePermissionViewModel extends ViewModel
{
    StringBinding roleCodeName;
    StringBinding roleDisplayName;
    StringBinding roleDescription;

    StringBinding permissionCodeName;
    StringBinding permissionDisplayName;
    StringBinding permissionDescription;
    StringBinding permissionResource;

	RoleListViewModel _roleListViewModel;
	PermissionListViewModel _permissionListViewModel;

	RolePermissionViewModel(
		this._roleListViewModel,
		this._permissionListViewModel,
		[
			ParentChildModel model
		])
	{
		roleCodeName = new StringBinding();
		roleDisplayName = new StringBinding();
		roleDescription = new StringBinding();

		permissionCodeName = new StringBinding();
		permissionDisplayName = new StringBinding();
		permissionDescription = new StringBinding();
		permissionResource = new StringBinding();

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	ParentChildModel _model;
	ParentChildModel get model => _model;

	void set model(ParentChildModel value)
	{
		_model = value;

		if (value == null)
		{
			roleCodeName.getter = null;
			roleDisplayName.getter = null;
			roleDescription.getter = null;

			permissionCodeName.getter = null;
			permissionDisplayName.getter = null;
			permissionDescription.getter = null;
			permissionResource.getter = null;
		}
		else
		{
			var roleId = value.parentId;
			var permissionId = value.childId;

			ViewModelGetter<RoleViewModel> roleViewModel = ()
			{
				return _roleListViewModel.roles.findViewModel((roleViewModel) => roleViewModel.id == roleId);
			};

			ViewModelGetter<PermissionViewModel> permissionViewModel = ()
			{
				return _permissionListViewModel.permissions.findViewModel((permissionViewModel) => permissionViewModel.id == permissionId);
			};

			roleCodeName.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.codeName.getter();
			};

			roleDisplayName.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.displayName.getter();
			};

			roleDescription.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.description.getter();
			};

			permissionCodeName.getter = ()
			{
				var vm  = permissionViewModel();
				if (vm == null) return '';
				return vm.codeName.getter();
			};

			permissionDisplayName.getter = ()
			{
				var vm  = permissionViewModel();
				if (vm == null) return '';
				return vm.displayName.getter();
			};

			permissionDescription.getter = ()
			{
				var vm  = permissionViewModel();
				if (vm == null) return '';
				return vm.description.getter();
			};

			permissionResource.getter = ()
			{
				var vm  = permissionViewModel();
				if (vm == null) return '';
				return vm.resource.getter();
			};

		}

		loaded();
	}

	String toString() => _model.toString();
}

