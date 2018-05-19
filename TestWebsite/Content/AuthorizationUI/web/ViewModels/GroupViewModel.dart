import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../Server.dart';
import '../ViewModels/AuthorizationViewModel.dart';
import '../ViewModels/RoleViewModel.dart';
import '../ViewModels/GroupRoleListViewModel.dart';
import '../ViewModels/GroupRoleViewModel.dart';
import '../Models/ParentChildModel.dart';
import '../Models/GroupModel.dart';

class GroupViewModel extends ViewModel
{
    StringBinding codeName;
    StringBinding displayName;
    StringBinding description;
    ViewModelList<RoleViewModel> assignedRoles;
    ViewModelList<RoleViewModel> otherRoles;

    int id;

    AuthorizationViewModel _authorizationViewModel;

    GroupViewModel(this._authorizationViewModel,[GroupModel model])
    {
        codeName = new StringBinding();
        displayName = new StringBinding();
        description = new StringBinding();
        assignedRoles = new ViewModelList<RoleViewModel>(null);
        otherRoles = new ViewModelList<RoleViewModel>(null);

        this.model = model;
    }

    dispose()
    {
        model = null;
    }

    GroupModel _model;
    GroupModel get model => _model;

    void set model(GroupModel value)
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

            if (_authorizationViewModel.roleList.isLoaded)
                _authorizationViewModel.groupRoleList.whenLoaded(_loadGroupRoles);
            else
                _authorizationViewModel.roleList.whenLoaded(_loadRoles);
        }

        _rolesToAdd = new List<int>();
        _rolesToRemove = new List<int>();

        loaded();
    }

    void _loadRoles(ViewModel permissionListViewModel)
    {
        _authorizationViewModel.groupRoleList.whenLoaded(_loadGroupRoles);
    }

    void _loadGroupRoles(GroupRoleListViewModel groupRoleList)
    {
        var rolePermissionModels = groupRoleList.models;
        if (rolePermissionModels == null) return;

        var assignedPermissionList = new List<RoleViewModel>();
        var otherPermissionList = new List<RoleViewModel>();

        for (var role in _authorizationViewModel.roleList.roles.viewModels)
        {
            if (groupRoleList.groupRoles.findIndex((GroupRoleViewModel gr) => gr.groupId == id && gr.roleId == role.id) == -1)
                otherPermissionList.add(role);
            else            
                assignedPermissionList.add(role);
        }

        assignedRoles.viewModels = assignedPermissionList;
        otherRoles.viewModels = otherPermissionList;
    }

    List<int> _rolesToAdd;
    List<int> _rolesToRemove;

    void assignRole(RoleViewModel role)
    {
        assignedRoles.addViewModel(role);
        otherRoles.deleteViewModel(role);

        var roleId = role.id;
        if (_rolesToRemove.contains(roleId))
        {
            _rolesToRemove.remove(roleId);
            modified();
        }
        else
        {
            if (!_rolesToAdd.contains(roleId))
            {
                _rolesToAdd.add(roleId);
                modified();
            }
        }
    }

    void removeRole(RoleViewModel role)
    {
        assignedRoles.deleteViewModel(role);
        otherRoles.addViewModel(role);

        var roleId = role.id;
        if (_rolesToAdd.contains(roleId))
        {
            _rolesToAdd.remove(roleId);
            modified();
        }
        else
        {
            if (!_rolesToRemove.contains(roleId))
            {
                _rolesToRemove.add(roleId);
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
                .getGroup(_model.id)
                .then((m) => model = m);
        }
    }

    Future<SaveResult> saveChanges(ChangeState state, bool alert) async
    {
        SaveResult result = SaveResult.unmodified;
        String alertMessage;
        bool rolesChanged = false;
        var allGroupRoles = _authorizationViewModel.groupRoleList.groupRoles;

        if (_rolesToAdd.length > 0)
        {
            rolesChanged = true;
            for (var roleId in _rolesToAdd)
            {
                var model = new ParentChildModel(null)
                    ..parentId = id
                    ..childId = roleId;
                 allGroupRoles.addModel(model);
            }
        }

        if (_rolesToRemove.length > 0)
        {
            rolesChanged = true;
            for (var roleId in _rolesToRemove)
            {
                var index = allGroupRoles.findIndex(
                    (GroupRoleViewModel vm)
                    {
                        var model = vm.model;
                        return model.parentId == id && model.childId == roleId; 
                    });
                 allGroupRoles.delete(index);
            }
        }

        if (rolesChanged)
        {
            _authorizationViewModel.groupRoleList.save(false);
        }

        if (state == ChangeState.modified)
        {
            var response = await Server.updateGroup(model);
            if (response.isSuccess)
            {
                result = SaveResult.saved;
                // alertMessage = 'Changes to "' + model.displayName + '" group successfully saved';
            }
            else
            {
                result = SaveResult.failed;
                alertMessage = 'Changes to "' + model.displayName + '" group were not saved. ' + response.error;
            }
        }
        else if (state == ChangeState.added)
        {
            var response = await Server.createGroup(model);
            if (response.isSuccess)
            {
                _model.id = response.id;
                result = SaveResult.saved;
                alertMessage = 'New "' + model.displayName + '" group successfully added';
            }
            else
            {
                result = SaveResult.failed;
                alertMessage = 'New "' + model.displayName + '" group was not added. ' + response.error;
            }
        }
        else if (state == ChangeState.deleted)
        {
            result = SaveResult.failed;
            alertMessage = 'Deleting groups requires another group to assign the users to';
        }
        else
        {
            alertMessage = 'There were no changes to the "' + model.displayName + '" group to save';
        }

        if (alert && alertMessage != null && alertMessage.length > 0)
            MvvmEvents.alert.raise(alertMessage);

        return result;
    }

    String toString() => _model.toString();
}

