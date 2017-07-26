import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/PermissionModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Permissions/PermissionEditFormView.dart';

class PermissionDeleteView extends EditView
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	PermissionDeleteView(this._permissionListViewModel, [PermissionViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addDiv(),
			formatMethod: (s) => 
				'<p>Are you sure you want to delete the "' + s +
				'" permission.</p><p>Deleting this permission could prevent some users from ' +
				'accessing features of the system that they currently have access to.</p>');

		_descriptionBinding = new BoundLabel<String>(addDiv());

		this.viewModel = viewModel;
	}

	PermissionViewModel _viewModel;
	PermissionViewModel get viewModel => _viewModel;

	PermissionListViewModel _permissionListViewModel;

	void set viewModel(PermissionViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
		}
	}

	void deleteRecord(void onSuccess())
	{
		_permissionListViewModel.permissions.deleteViewModel(_viewModel);

		_permissionListViewModel.save()
			.then((SaveResult result)
			{
				if (result == SaveResult.saved)
					onSuccess();
			});
	}
}