import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';
import '../../MVVM/BoundRepeater.dart';

import '../../Models/ParentChildModel.dart';

import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupRoleViewModel.dart';
import '../../ViewModels/GroupRoleListViewModel.dart';

import '../../Views/Groups/GroupRoleView.dart';

class GroupDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
	BoundLabel<String> _codeNameBinding;

	BoundLabel<String> _nameBinding1;

	BoundRepeater<ParentChildModel, GroupRoleViewModel, GroupRoleView> _roleListBinding;

	GroupRoleListViewModel _groupRoleListViewModel;

	GroupDisplayView(
		this._groupRoleListViewModel,
		[
			GroupViewModel viewModel
		])
	{
		addBlockText(
			'<p>A <b>Group</b> is a set of users that have identical permissions, i.e. all users in ' +
			'the same group have exactly the same restrictions on what they are allowed to do ' +
			'within the system. Each user can be assigned to a single group. Unassigned users ' +
			'belong to the <b>Default Group</b>. There is also a special <b>Administrators</b> '
			'group that have unrestricted access to the system.</p>', 
			className: 'help-note');

		var form = addForm();
		_displayNameBinding = new BoundLabel<String>(addLabeledField(form, 'Display name'));
		_descriptionBinding = new BoundLabel<String>(addLabeledField(form, 'Description'));
		_codeNameBinding = new BoundLabel<String>(addLabeledField(form, 'Code name'));

		addHR();

		_nameBinding1 = new BoundLabel<String>(
			addHeading(3, 'Group roles'), 
			formatMethod: (s) => s + ' roles');

		addBlockText(
			'<p>Roles are assigned to groups to give all of the users in that group access to ' +
			'specific functions within the system.</p>', 
			className: 'help-note');

		var tableRow = addDiv(className: 'tr', parent: addDiv(className: 'table'));
		addDiv(html:'Name', classNames: ['th', 'display-name', 'role'], parent: tableRow);
		addDiv(html:'Description', classNames: ['th', 'description', 'role'], parent: tableRow);

		_roleListBinding = new BoundRepeater<ParentChildModel, GroupRoleViewModel, GroupRoleView>
			((vm) => new GroupRoleView(vm), addDiv(className: 'table'))
			..binding = _groupRoleListViewModel.groupRoles;

		this.viewModel = viewModel;
	}

	GroupViewModel _viewModel;
	GroupViewModel get viewModel => _viewModel;

	void set viewModel(GroupViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
			_codeNameBinding.binding = null;

			_nameBinding1.binding = null;

			_roleListBinding.viewModelFilter = (vm) => false;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;

			_nameBinding1.binding = value.displayName;

			_roleListBinding.viewModelFilter = (vm) => vm.model.parentId == value.model.id;
			_roleListBinding.refresh();
		}
	}

	reload()
	{
		if (_viewModel != null)
			_viewModel.reload();
	}

}