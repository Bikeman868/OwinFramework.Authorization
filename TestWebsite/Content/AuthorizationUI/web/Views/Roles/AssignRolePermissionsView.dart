import '../../MVVM/Mvvm.dart';
import '../../Models/PermissionModel.dart';
import '../../Models/ParentChildModel.dart';
import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/RolePermissionsViewModel.dart';
import '../Permissions/PermissionUnassignedView.dart';
import '../Permissions/PermissionAssignedView.dart';

class AssignRolePermissionsView extends View
{
  RolePermissionsViewModel _rolePermissions;

  BoundViewModelList<PermissionViewModel, PermissionAssignedView> _assignedPermissionsBinding;
  BoundViewModelList<PermissionViewModel, PermissionUnassignedView> _otherPermissionsBinding;

	AssignRolePermissionsView(
    this._authorizationViewModel, 
    [RoleViewModel roleViewModel])
	{
		addHeading(3,	'Currently assigned permissions');

		addBlockText(
			'<p>These are the permissions currently assigned to this role. Removing permissions from ' +
      'this role could affect all users that have this role unless the same permission is granted '+
      'to them via another role.</p>', 
			className: 'help-note');

		_assignedPermissionsBinding = new BoundViewModelListRepeater<PermissionViewModel, PermissionAssignedView>(
			(vm) => new PermissionAssignedView(_removePermission, vm), addDiv());

		addHeading(3, 'Other permissions');

		addBlockText(
			'<p>These are the permissions not currently assigned to this role. Adding permissions to this ' +
      'role will grant this permission to all users who have this role.',
			className: 'help-note');

		_otherPermissionsBinding = new BoundViewModelListRepeater<PermissionViewModel, PermissionUnassignedView>(
			(vm) => new PermissionUnassignedView(_addPermission, vm), addDiv());

    _rolePermissions = new RolePermissionsViewModel(_authorizationViewModel, roleViewModel);
    viewModel = roleViewModel;
	}

  AuthorizationViewModel _authorizationViewModel;

	RoleViewModel _viewModel;
	RoleViewModel get viewModel => _viewModel;

	void set viewModel(RoleViewModel value)
	{
    _rolePermissions.roleViewModel = value;
    _assignedPermissionsBinding.binding = _rolePermissions.assignedPermissions;
    _otherPermissionsBinding.binding = _rolePermissions.otherPermissions;
	}

  void _removePermission(PermissionViewModel permission)
  {
    _rolePermissions.revokePermission(permission);
  }

  void _addPermission(PermissionViewModel permission)
  {
    _rolePermissions.grantPermission(permission);
  }
}