import '../../MVVM/Mvvm.dart';
import '../../Models/ParentChildModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/GroupRoleViewModel.dart';
import '../../ViewModels/GroupRoleListViewModel.dart';
import '../../ViewModels/RolePermissionViewModel.dart';
import '../../ViewModels/RolePermissionListViewModel.dart';
import '../../Views/Roles/RoleGroupView.dart';
import '../../Views/Roles/RolePermissionView.dart';

class RoleDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
	BoundLabel<String> _codeNameBinding;

	BoundLabel<String> _nameBinding1;
	BoundLabel<String> _nameBinding2;
	BoundLabel<String> _nameBinding3;
	BoundLabel<String> _nameBinding4;

	BoundModelListRepeater<ParentChildModel, GroupRoleViewModel, RoleGroupView> _groupListBinding;
	BoundModelListRepeater<ParentChildModel, RolePermissionViewModel, RolePermissionView> _permissionListBinding;

	GroupRoleListViewModel _groupRoleListViewModel;
	RolePermissionListViewModel _rolePermissionListViewModel;

	RoleDisplayView(
		AuthorizationViewModel authorizationViewModel,
		[
			RoleViewModel viewModel
		])
	{
		_groupRoleListViewModel = authorizationViewModel.groupRoleList;
		_rolePermissionListViewModel = authorizationViewModel.rolePermissionList;

		addBlockText(
			'<p>A <b>Role</b> is a set of permissions that are required to perform a specific function. ' +
			'For example in order to do the job of customer service representative users must ' +
			'be given access to specific features within the system, therefore customer service representative '
			'is a role.</p>', 
			className: 'help-note');

		var form = addForm();
		_displayNameBinding = new BoundLabel<String>(addLabeledField(form, 'Display name'));
		_descriptionBinding = new BoundLabel<String>(addLabeledField(form, 'Description'));
		_codeNameBinding = new BoundLabel<String>(addLabeledField(form, 'Code name'));

		addHR();

		_nameBinding1 = new BoundLabel<String>(
			addHeading(3, 'Role groups'), 
			formatMethod: (s) => s + ' groups');
		
		_nameBinding2 = new BoundLabel<String>(
			addBlockText('', className: 'help-note'),
			formatMethod: (s) => 
				'<p>These are the groups that will be affected by ' +
				'any changes you make to the "' + s + '" role.</p>');

		var groupTableHeader = addDiv(className: 'tr', parent: addDiv(className: 'table'));
		addDiv(html:'Name', classNames: ['th', 'display-name', 'role'], parent: groupTableHeader);
		addDiv(html:'Description', classNames: ['th', 'description', 'role'], parent: groupTableHeader);

		_groupListBinding = new BoundModelListRepeater<ParentChildModel, GroupRoleViewModel, RoleGroupView>(
			(vm) => new RoleGroupView(vm), addDiv(className: 'table'))
			..binding = _groupRoleListViewModel.groupRoles;

		addHR();

		_nameBinding3 = new BoundLabel<String>(
			addHeading(3, 'Role permissions'), 
			formatMethod: (s) => s + ' permissions');

		_nameBinding4 = new BoundLabel<String>(
			addBlockText('', className: 'help-note'),
			formatMethod: (s) => 
				'<p>These are the permissions that will be granted when the "' + s +
				'" role is assigned to a group of users.</p>');

		var permissionTableHeader = addDiv(className: 'tr', parent: addDiv(className: 'table'));
		addDiv(html:'Name', classNames: ['th', 'display-name', 'role'], parent: permissionTableHeader);
		addDiv(html:'Description', classNames: ['th', 'description', 'role'], parent: permissionTableHeader);

		_permissionListBinding = new BoundModelListRepeater<ParentChildModel, RolePermissionViewModel, RolePermissionView>
			((vm) => new RolePermissionView(vm), addDiv(className: 'table'))
			..binding = _rolePermissionListViewModel.rolePermissions;

		this.viewModel = viewModel;
	}

	RoleViewModel _viewModel;
	RoleViewModel get viewModel => _viewModel;

	void set viewModel(RoleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
			_codeNameBinding.binding = null;

			_nameBinding1.binding = null;
			_nameBinding2.binding = null;
			_nameBinding3.binding = null;
			_nameBinding4.binding = null;

			_groupListBinding.viewModelFilter = (vm) => false;
			_permissionListBinding.viewModelFilter = (vm) => false;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;

			_nameBinding1.binding = value.displayName;
			_nameBinding2.binding = value.displayName;
			_nameBinding3.binding = value.displayName;
			_nameBinding4.binding = value.displayName;

			_groupListBinding.viewModelFilter = (vm) => vm.model.childId == value.model.id;
			_groupListBinding.refresh();

			_permissionListBinding.viewModelFilter = (vm) => vm.model.parentId == value.model.id;
			_permissionListBinding.refresh();
		}
	}

	reload()
	{
		if (_viewModel != null)
			_viewModel.reload();
	}

}