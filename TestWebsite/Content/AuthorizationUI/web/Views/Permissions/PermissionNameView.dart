import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/PermissionViewModel.dart';

class PermissionNameView extends View
{
	BoundLabel<String> _displayNameBinding;

	PermissionNameView([PermissionViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addSpan(classNames: ['permission', 'codeName']), 
			formatMethod: (s) => s + ' ');

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
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
		}
	}
}

