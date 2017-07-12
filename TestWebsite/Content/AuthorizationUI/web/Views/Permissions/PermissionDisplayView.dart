import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/PermissionViewModel.dart';

class PermissionDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
	BoundLabel<String> _codeNameBinding;
	BoundLabel<String> _resourceBinding;

	PermissionDisplayView([PermissionViewModel viewModel])
	{
		var form = addForm();
		_displayNameBinding = new BoundLabel<String>(addLabeledField(form, 'Display name'));
		_descriptionBinding = new BoundLabel<String>(addLabeledField(form, 'Description'));
		_codeNameBinding = new BoundLabel<String>(addLabeledField(form, 'Code name'));
		_resourceBinding = new BoundLabel<String>(addLabeledField(form, 'Resource expression'));

		addHeading(3, 'Roles that have this permission');

		addBlockText('Role 1');
		addBlockText('Role 2');
		addBlockText('Role 3');

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
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;
			_resourceBinding.binding = value.resource;
		}
	}

}