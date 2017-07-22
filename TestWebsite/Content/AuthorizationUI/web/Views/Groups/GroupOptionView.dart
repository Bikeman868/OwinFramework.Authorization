import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/GroupViewModel.dart';

class GroupOptionView extends View
{
	BoundLabel<String> _displayNameBinding;

	GroupOptionView([GroupViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addDropdownListElement(classNames: ['group', 'codeName']));

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
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
		}
	}
}

