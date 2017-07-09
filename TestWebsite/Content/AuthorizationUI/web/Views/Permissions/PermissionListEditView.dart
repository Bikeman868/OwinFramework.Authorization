import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/Enums.dart';

import '../../Models/PermissionModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Permissions/PermissionNameView.dart';

class PermissionListEditView extends EditView
{
	BoundList<PermissionModel, PermissionViewModel, PermissionNameView> _permissionsBinding;

	PermissionListEditView([PermissionListViewModel viewModel])
	{
		addBlockText(
			'<p>Remove permissions that you no longer need. If your application ' +
			'is checking a permission before allowing access to a feature and you ' +
			'remove that permission, then the feature will become unavailable. In ' +
			'general only the software development team should manage permissions ' +
			'because they know which permissions the application is checking for.</p>',
			className: 'help-note');

		_permissionsBinding = new BoundList<PermissionModel, PermissionViewModel, PermissionNameView>(
			(vm) => new PermissionNameView(vm), addList(), allowAdd: false);

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

	void saveEdits(void onSuccess())
	{
		viewModel.save()
			.then((SaveResult saveResult)
			{
				if (saveResult == SaveResult.saved || 
					saveResult == SaveResult.unmodified)
					onSuccess();
			});
	}

	void cancelEdits(void onSuccess())
	{
		viewModel.undelete();
		onSuccess();
	}
}