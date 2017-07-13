﻿import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/GroupViewModel.dart';

class GroupDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
	BoundLabel<String> _codeNameBinding;

	BoundLabel<String> _nameBinding1;
	BoundLabel<String> _nameBinding2;

	GroupDisplayView([GroupViewModel viewModel])
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

		addBlockText('Role 1');
		addBlockText('Role 2');
		addBlockText('Role 3');

		addHR();

		_nameBinding2 = new BoundLabel<String>(
			addHeading(3, 'Group permissions'), 
			formatMethod: (s) => s + ' permissions');

		addBlockText(
			'<p>This is a combination of all of the permissions assigned to all of the roles ' +
			'assigned to this group. To alter this list of permissions either add/remove roles ' +
			'on the group, or modify the permissions assigned to the roles.</p>', 
			className: 'help-note');

		addBlockText('Permission 1');
		addBlockText('Permission 2');
		addBlockText('Permission 3');

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
			_nameBinding2.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;

			_nameBinding1.binding = value.displayName;
			_nameBinding2.binding = value.displayName;
		}
	}

}