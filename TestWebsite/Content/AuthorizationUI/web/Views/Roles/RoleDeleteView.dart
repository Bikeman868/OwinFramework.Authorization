import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Enums.dart';
import '../../MVVM/BoundLabel.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/RoleModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/RoleListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Roles/RoleEditFormView.dart';

class RoleDeleteView extends EditView
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	RoleDeleteView(this._roleListViewModel, [RoleViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addDiv(),
			formatMethod: (s) => 
				'<p>Are you sure you want to delete the "' + s +
				'" role.</p><p>Deleting this role will remove the permissions granted by ' +
				'this role from any groups that have this role assigned to them.</p>');

		_descriptionBinding = new BoundLabel<String>(addDiv());

		this.viewModel = viewModel;
	}

	RoleViewModel _viewModel;
	RoleViewModel get viewModel => _viewModel;

	RoleListViewModel _roleListViewModel;

	void set viewModel(RoleViewModel value)
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
		_roleListViewModel.roles.deleteViewModel(_viewModel);

		_roleListViewModel.save()
			.then((SaveResult result)
			{
				if (result == SaveResult.saved)
					onSuccess();
			});
	}
}