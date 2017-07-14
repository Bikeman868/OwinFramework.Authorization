import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundRepeater.dart';

import '../../Models/ParentChildModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/RolePermissionViewModel.dart';
import '../../ViewModels/RolePermissionListViewModel.dart';

import '../../Views/Permissions/PermissionRoleView.dart';

class PermissionDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
	BoundLabel<String> _codeNameBinding;
	BoundLabel<String> _resourceBinding;

	BoundRepeater<ParentChildModel, RolePermissionViewModel, PermissionRoleView> _permissionListBinding;

	RolePermissionListViewModel _rolePermissionListViewModel;

	PermissionDisplayView(
		this._rolePermissionListViewModel,
		[
			PermissionViewModel viewModel
		])
	{
		addBlockText(
			'<p>A <b>Permission</b> is something that is tested by the system before allowing access ' +
			'to a specific feature. For example when the logged on user invokes the "delete order" feature ' +
			'the system will check that the user has permission to delete orders before continuing.</p>', 
			className: 'help-note');

		var form = addForm();
		_displayNameBinding = new BoundLabel<String>(addLabeledField(form, 'Display name'));
		_descriptionBinding = new BoundLabel<String>(addLabeledField(form, 'Description'));
		_codeNameBinding = new BoundLabel<String>(addLabeledField(form, 'Code name'));
		_resourceBinding = new BoundLabel<String>(addLabeledField(form, 'Resource expression'));

		addBlockText(
			'<p>When the system tests if the user has a specific permission it is usually in the context ' +
			'of a protected resource. When you create permissions here you can optionally specify a '
			'resource expression, in which case the user is only granted this permission on resources ' +
			'that match the resource expression.</p>', 
			className: 'help-note');

		addHR();
		addHeading(3, 'Roles');

		addBlockText(
			'<p>These are the roles that grant this permission. If you modify this permission then '
			'groups that have any of these roles assigned to them will be affected.</p>', 
			className: 'help-note');

		var permissionTableHeading = addDiv(className: 'tr', parent: addDiv(className: 'table'));
		addDiv(html:'Name', classNames: ['th', 'display-name', 'role'], parent: permissionTableHeading);
		addDiv(html:'Description', classNames: ['th', 'description', 'role'], parent: permissionTableHeading);

		_permissionListBinding = new BoundRepeater<ParentChildModel, RolePermissionViewModel, PermissionRoleView>
			((vm) => new PermissionRoleView(vm), addDiv(className: 'table'))
			..binding = _rolePermissionListViewModel.rolePermissions;


		this.viewModel = viewModel;
	}

	PermissionViewModel _viewModel;
	PermissionViewModel get viewModel => _viewModel;

	void set viewModel(PermissionViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
			_codeNameBinding.binding = null;
			_resourceBinding.binding = null;

			_permissionListBinding.viewModelFilter = (vm) => false;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;
			_resourceBinding.binding = value.resource;

			_permissionListBinding.viewModelFilter = (vm) => vm.model.childId == value.model.id;
			_permissionListBinding.refresh();
		}
	}

	reload()
	{
		if (_viewModel != null)
			_viewModel.reload();
	}

}