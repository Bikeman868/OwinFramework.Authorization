import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundRepeater.dart';

import '../../Models/ParentChildModel.dart';

import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/GroupRoleViewModel.dart';
import '../../ViewModels/GroupRoleListViewModel.dart';

import '../../Views/Roles/RoleGroupView.dart';

class RoleDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
	BoundLabel<String> _codeNameBinding;

	BoundLabel<String> _nameBinding1;
	BoundLabel<String> _nameBinding2;
	BoundLabel<String> _nameBinding3;
	BoundLabel<String> _nameBinding4;

	BoundRepeater<ParentChildModel, GroupRoleViewModel, RoleGroupView> _groupListBinding;

	GroupRoleListViewModel _groupRoleListViewModel;

	RoleDisplayView(
		this._groupRoleListViewModel,
		[
			RoleViewModel viewModel
		])
	{
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

		var tableRow = addDiv(className: 'tr', parent: addDiv(className: 'table'));
		addDiv(html:'Name', classNames: ['th', 'display-name', 'role'], parent: tableRow);
		addDiv(html:'Description', classNames: ['th', 'description', 'role'], parent: tableRow);

		_groupListBinding = new BoundRepeater<ParentChildModel, GroupRoleViewModel, RoleGroupView>(
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

		addBlockText('Permission 1');
		addBlockText('Permission 2');
		addBlockText('Permission 3');

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
		}
	}

	reload()
	{
		if (_viewModel != null)
			_viewModel.reload();
	}

}