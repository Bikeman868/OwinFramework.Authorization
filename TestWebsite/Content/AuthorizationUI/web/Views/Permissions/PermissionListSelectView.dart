import '../../MVVM/Mvvm.dart';
import '../../Events/AppEvents.dart';
import '../../Models/PermissionModel.dart';
import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import 'PermissionNameView.dart';

class PermissionListSelectView extends View
{
	BoundList<PermissionModel, PermissionViewModel, PermissionNameView> _permissionsBinding;

	PermissionListSelectView([PermissionListViewModel viewModel])
	{
		addBlockText(
			'These are the currently defined permissions in this system. Granting a permission to ' +
			'a group of users will give them access to functionallity within the system.', 
			className: 'help-note');

		_permissionsBinding = new BoundList<PermissionModel, PermissionViewModel, PermissionNameView>(
			(vm) => new PermissionNameView(vm), addList(), allowAdd: false, allowRemove: false,
			selectionMethod: (vm) => AppEvents.permissionSelected.raise(new PermissionSelectedEvent(vm)));

		this.viewModel = viewModel;
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