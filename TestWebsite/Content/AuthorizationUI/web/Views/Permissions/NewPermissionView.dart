import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';

import '../../Models/PermissionModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import 'PermissionNameView.dart';

class NewPermissionView extends View
{
	BoundList<PermissionModel, PermissionViewModel, PermissionNameView> _permissionsBinding;

	NewPermissionView([PermissionListViewModel viewModel])
	{
		addBlockText('Create a new permission', className: 'help-note');

		_permissionsBinding = new BoundList<PermissionModel, PermissionViewModel, PermissionNameView>(
			(vm) => new PermissionNameView(vm), 
			addList());
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