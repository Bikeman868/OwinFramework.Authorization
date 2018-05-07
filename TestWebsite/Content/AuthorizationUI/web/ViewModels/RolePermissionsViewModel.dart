import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../ViewModels/AuthorizationViewModel.dart';
import '../ViewModels/RoleViewModel.dart';
import '../ViewModels/PermissionViewModel.dart';

// Manages a bindable list of the permissions assigned to a role
class RolePermissionsViewModel extends ViewModel
{
  ViewModelList<PermissionViewModel> assignedPermissions;
  ViewModelList<PermissionViewModel> otherPermissions;

	AuthorizationViewModel _authorizationViewModel;
  RoleViewModel _roleViewModel;

  StreamSubscription<ListEvent> _permissionAddedSubscription;
  StreamSubscription<ListEvent> _permissionRemovedSubscription;
  StreamSubscription<ListEvent> _permissionsChangedSubscription;

	RolePermissionsViewModel(
		this._authorizationViewModel,
		this._roleViewModel)
	{
		assignedPermissions = new ViewModelList<PermissionViewModel>(null);
    _permissionAddedSubscription = assignedPermissions.onAdd.listen(_permissionAdded);
    _permissionRemovedSubscription = assignedPermissions.onDelete.listen(_permissionRemoved);
    _permissionsChangedSubscription = assignedPermissions.onListChanged.listen(_permissionsChanged);

		otherPermissions = new ViewModelList<PermissionViewModel>(null);

    reload();
	}

  dispose()
  {
    _permissionAddedSubscription.cancel();
    _permissionRemovedSubscription.cancel();
    _permissionsChangedSubscription.cancel();
  }

  RoleViewModel get roleViewModel => _roleViewModel;

  void set roleViewModel(RoleViewModel value)
  {
    _roleViewModel = value;
    reload();
  }

  bool _reloading = false;

	void reload()
	{
    var assignedPermissionList = new List<PermissionViewModel>();
    var otherPermissionList = new List<PermissionViewModel>();

    var rolePermissions = _authorizationViewModel.rolePermissionList.models;
    if (_roleViewModel != null && rolePermissions != null)
    {
      for (var parentChild in rolePermissions)
      {
        var permissionId = parentChild.childId;
        var permission = _authorizationViewModel.permissionList.permissions.findViewModel((vm) => vm.id == permissionId);
        if (permission != null)
        {
          if (parentChild.parentId == _roleViewModel.id)
          {
            assignedPermissionList.add(permission);
          }
          else
          {
            otherPermissionList.add(permission);
          }
        }
      }
    }

    _reloading = true;
    try
    {
      assignedPermissions.viewModels = assignedPermissionList;
      otherPermissions.viewModels = otherPermissionList;
    }
    finally
    {
      _reloading = false;
    }
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
  {
    // TODO: Save the changes
    return SaveResult.saved;
  }

  void _permissionAdded(ListEvent event)
  {
    if (_reloading) return;
  }

  void _permissionRemoved(ListEvent event)
  {
    if (_reloading) return;
  }

  void _permissionsChanged(ListEvent event)
  {
    if (_reloading) return;
  }

	String toString() => 'permissions for ' + _roleViewModel.toString();
}

