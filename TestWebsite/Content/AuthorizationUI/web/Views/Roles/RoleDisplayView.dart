import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/RoleViewModel.dart';

class RoleDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
	BoundLabel<String> _codeNameBinding;

	RoleDisplayView([RoleViewModel viewModel])
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

		addHeading(3, 'Role groups');

		addBlockText(
			'<p>These are the groups that will be affected by any changes you make to this role.</p>', 
			className: 'help-note');

		addBlockText('Group 1');
		addBlockText('Group 2');
		addBlockText('Group 3');

		addHeading(3, 'Role permissions');

		addBlockText(
			'<p>These are the permissions that will be granted when this role is assigned to a '
			'group of users.</p>', 
			className: 'help-note');

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
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;
		}
	}

}