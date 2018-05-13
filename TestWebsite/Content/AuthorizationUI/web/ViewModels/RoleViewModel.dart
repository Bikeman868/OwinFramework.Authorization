import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../Server.dart';
import '../ViewModels/AuthorizationViewModel.dart';
import '../ViewModels/PermissionViewModel.dart';
import '../ViewModels/RolePermissionListViewModel.dart';
import '../ViewModels/RolePermissionViewModel.dart';
import '../Models/ParentChildModel.dart';
import '../Models/RoleModel.dart';

class RoleViewModel extends ViewModel
{
    StringBinding codeName;
    StringBinding displayName;
    StringBinding description;
    ViewModelList<PermissionViewModel> assignedPermissions;
    ViewModelList<PermissionViewModel> otherPermissions;

    int id;

    AuthorizationViewModel _authorizationViewModel;

    RoleViewModel(
    this._authorizationViewModel, 
    [
        RoleModel model
    ])
    {
        codeName = new StringBinding();
        displayName = new StringBinding();
        description = new StringBinding();
        assignedPermissions = new ViewModelList<PermissionViewModel>(null);
        otherPermissions = new ViewModelList<PermissionViewModel>(null);

        this.model = model;
    }

    dispose()
    {
        model = null;
    }

    RoleModel _model;
    RoleModel get model => _model;

    void set model(RoleModel value)
    {
        _model = value;

        if (value == null)
        {
            codeName.setter = null;
            codeName.getter = null;
        
            displayName.setter = null;
            displayName.getter = null;

            description.setter = null;
            description.getter = null;
        }
        else
        {
            id = value.id;

            codeName.setter = (String text) 
            { 
                value.codeName = text;
                modified();
            };
            codeName.getter = () => value.codeName;
        
            displayName.setter = (String text) 
            { 
                value.displayName = text; 
                modified();
            };
            displayName.getter = () => value.displayName;
        
            description.setter = (String text) 
            { 
                value.description = text; 
                modified();
            };
            description.getter = () => value.description;

            if (_authorizationViewModel.permissionList.isLoaded)
                _authorizationViewModel.rolePermissionList.whenLoaded(_loadRolePermissions);
            else
                _authorizationViewModel.permissionList.whenLoaded(_loadPermissions);
        }

        _permissionsToAdd = new List<int>();
        _permissionsToRemove = new List<int>();

        loaded();
    }

    void _loadPermissions(ViewModel permissionListViewModel)
    {
        _authorizationViewModel.rolePermissionList.whenLoaded(_loadRolePermissions);
    }

    void _loadRolePermissions(RolePermissionListViewModel rolePermissionList)
    {
        var rolePermissionModels = rolePermissionList.models;
        if (rolePermissionModels == null) return;

        var assignedPermissionList = new List<PermissionViewModel>();
        var otherPermissionList = new List<PermissionViewModel>();

        for (var permission in _authorizationViewModel.permissionList.permissions.viewModels)
        {
            if (rolePermissionList.rolePermissions.findIndex((RolePermissionViewModel rp) => rp.roleId == id && rp.permissionId == permission.id) == -1)
                otherPermissionList.add(permission);
            else            
                assignedPermissionList.add(permission);
        }

        assignedPermissions.viewModels = assignedPermissionList;
        otherPermissions.viewModels = otherPermissionList;
    }

    List<int> _permissionsToAdd;
    List<int> _permissionsToRemove;

    void grantPermission(PermissionViewModel permission)
    {
        assignedPermissions.addViewModel(permission);
        otherPermissions.deleteViewModel(permission);

        var permissionId = permission.id;
        if (_permissionsToRemove.contains(permissionId))
        {
            _permissionsToRemove.remove(permissionId);
            modified();
        }
        else
        {
            if (!_permissionsToAdd.contains(permissionId))
            {
                _permissionsToAdd.add(permissionId);
                modified();
            }
        }
    }

    void revokePermission(PermissionViewModel permission)
    {
        assignedPermissions.deleteViewModel(permission);
        otherPermissions.addViewModel(permission);

        var permissionId = permission.id;
        if (_permissionsToAdd.contains(permissionId))
        {
            _permissionsToAdd.remove(permissionId);
            modified();
        }
        else
        {
            if (!_permissionsToRemove.contains(permissionId))
            {
                _permissionsToRemove.add(permissionId);
                modified();
            }
        }
    }

    List<ModelList> getModelLists()
    {
        return [];
    }

    void reload()
    {
        if (_model != null)
        {
            Server
                .getRole(_model.id)
                .then((m) => model = m);
        }
    }

    Future<SaveResult> saveChanges(ChangeState state, bool alert) async
    {
        SaveResult result = SaveResult.unmodified;
        String alertMessage;
        bool permissionsChanged = false;
        var allRolePermissions = _authorizationViewModel.rolePermissionList.rolePermissions;

        if (_permissionsToAdd.length > 0)
        {
            permissionsChanged = true;
            for (var permissionId in _permissionsToAdd)
            {
                var model = new ParentChildModel(null)
                    ..parentId = id
                    ..childId = permissionId;
                 allRolePermissions.addModel(model);
            }
        }

        if (_permissionsToRemove.length > 0)
        {
            permissionsChanged = true;
            for (var permissionId in _permissionsToRemove)
            {
                var index = allRolePermissions.findIndex(
                    (RolePermissionViewModel vm)
                    {
                        var model = vm.model;
                        return model.parentId == id && model.childId == permissionId; 
                    });
                 allRolePermissions.delete(index);
            }
        }

        if (permissionsChanged)
        {
            _authorizationViewModel.rolePermissionList.save(false);
        }

        if (state == ChangeState.modified)
        {
            var response = await Server.updateRole(model);
            if (response.isSuccess)
            {
                result = SaveResult.saved;
                // alertMessage = 'Changes to "' + model.displayName + '" role successfully saved';
            }
            else
            {
                result = SaveResult.failed;
                alertMessage = 'Changes to "' + model.displayName + '" role were not saved. ' + response.error;
            }
        }
        else if (state == ChangeState.added)
        {
            var response = await Server.createRole(model);
            if (response.isSuccess)
            {
                _model.id = response.id;
                result = SaveResult.saved;
                alertMessage = 'New "' + model.displayName + '" role successfully added';
            }
            else
            {
                result = SaveResult.failed;
                alertMessage = 'New "' + model.displayName + '" role was not added. ' + response.error;
            }
        }
        else if (state == ChangeState.deleted)
        {
            var response = await Server.deleteRole(model.id);
            if (response.isSuccess)
            {
                result = SaveResult.saved;
                alertMessage = 'The "' + model.displayName + '" role was successfully deleted';
            }
            else
            {
                result = SaveResult.failed;
                alertMessage = 'The "' + model.displayName + '" role was not deleted. ' + response.error;
            }
        }
        else
        {
            if (!permissionsChanged)
                alertMessage = 'There were no changes to the "' + model.displayName + '" role to save';
        }

        if (alert && alertMessage != null && alertMessage.length > 0)
            MvvmEvents.alert.raise(alertMessage);

        return result;
    }

    String toString() => _model.toString();
}

