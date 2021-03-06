﻿import '../MVVM/Mvvm.dart';
import '../ViewModels/AuthorizationViewModel.dart';
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

	AuthorizationViewModel _authorizationViewModel;
	RoleListViewModel _roleListViewModel;
	PermissionListViewModel _permissionListViewModel;

	RolePermissionViewModel(
		this._authorizationViewModel,
		[
			ParentChildModel model
		])
	{
		_roleListViewModel = _authorizationViewModel.roleList;
		_permissionListViewModel = _authorizationViewModel.permissionList;

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

  int roleId;
  int permissionId;

	void set model(ParentChildModel value)
	{
		_model = value;

		if (value == null)
		{
			roleId = -1;
			permissionId = -1;

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
			roleId = value.parentId;
			permissionId = value.childId;

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

