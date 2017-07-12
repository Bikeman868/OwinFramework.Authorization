import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Enums.dart';
import '../../MVVM/BoundTextInput.dart';
import '../../MVVM/BoundTextArea.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/RoleModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/RoleViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Roles/EditRoleFormView.dart';

class RoleEditView extends EditView
{
	BoundTextInput<String> _displayNameBinding;
	BoundTextArea<String> _descriptionBinding;
	BoundTextInput<String> _codeNameBinding;
	BoundTextInput<String> _resourceBinding;

	RoleEditView([RoleViewModel viewModel])
	{
		var formView = merge(new EditRoleFormView()) as EditRoleFormView;

		_displayNameBinding = new BoundTextInput<String>(formView.displayName);
		_descriptionBinding = new BoundTextArea<String>(formView.description);
		_codeNameBinding = new BoundTextInput<String>(formView.codeName);
		_resourceBinding = new BoundTextInput<String>(formView.resource);

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

	void saveEdits(void onSuccess())
	{
		_viewModel.save();
		onSuccess();
	}
}