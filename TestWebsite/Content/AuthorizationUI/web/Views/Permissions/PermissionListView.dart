import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';

import '../../Models/PermissionModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import 'PermissionNameView.dart';

class PermissionListView extends View
{
	BoundList<PermissionModel, PermissionViewModel, PermissionNameView> _permissionsBinding;

	PermissionListView([PermissionListViewModel viewModel])
	{
		addHeading(3, 'Permissions');

		addBlockText('Choose an permission to edit.' + 
			'<br>You can also create new permissions and delete permissions here.' +
			'<br>The Save button will save all changes to all permissions'
			, className: 'help-note');

		_permissionsBinding = new BoundList<PermissionModel, PermissionViewModel, PermissionNameView>(
			(vm) => new PermissionNameView(vm), 
			addList());

		var buttonBar = addContainer(className: 'button-bar');
		addButton("Save", _saveClicked, parent: buttonBar);
		addButton("Discard", _discardClicked, parent: buttonBar);

		this.viewModel = viewModel;
	}

	void _saveClicked(MouseEvent e)
	{
		if (viewModel != null)
			viewModel.save();
	}

	void _discardClicked(MouseEvent e)
	{
		if (viewModel != null)
			viewModel.reload();
	}

	PermissionListViewModel _viewModel;
	PermissionListViewModel get viewModel => _viewModel;

	void set viewModel(PermissionListViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_permissionsBinding.binding = null;
		}
		else
		{
			_permissionsBinding.binding = value.permissions;
		}
	}
}