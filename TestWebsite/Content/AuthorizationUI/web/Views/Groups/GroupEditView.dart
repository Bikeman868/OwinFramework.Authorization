﻿import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Enums.dart';
import '../../MVVM/BoundTextInput.dart';
import '../../MVVM/BoundTextArea.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/GroupModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/GroupViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Groups/EditGroupFormView.dart';

class GroupEditView extends EditView
{
	BoundTextInput<String> _displayNameBinding;
	BoundTextArea<String> _descriptionBinding;
	BoundTextInput<String> _codeNameBinding;

	GroupEditView([GroupViewModel viewModel])
	{
		var formView = merge(new EditGroupFormView()) as EditGroupFormView;

		_displayNameBinding = new BoundTextInput<String>(formView.displayName);
		_descriptionBinding = new BoundTextArea<String>(formView.description);
		_codeNameBinding = new BoundTextInput<String>(formView.codeName);

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
			_descriptionBinding.binding = null;
			_codeNameBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;
		}
	}

	void saveEdits(void onSuccess())
	{
		_viewModel.save();
		onSuccess();
	}
}