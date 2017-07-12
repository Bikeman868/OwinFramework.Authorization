import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/Enums.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/GroupModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Groups/GroupNameView.dart';
import '../../Views/Groups/EditGroupFormView.dart';

class GroupListNewView extends EditView
{
	EditGroupFormView _formView;

	GroupListNewView([GroupListViewModel viewModel])
	{
		_formView = merge(new EditGroupFormView()) as EditGroupFormView;

		this.viewModel = viewModel;
	}

	GroupListViewModel _viewModel;
	GroupListViewModel get viewModel => _viewModel;

	void set viewModel(GroupListViewModel value)
	{
		_viewModel = value;
	}

	void clearForm()
	{
		_formView.codeName.value = '';
		_formView.displayName.value = '';
		_formView.description.value = '';

		_formView.displayName.focus();
	}

	void saveEdits(void onSuccess())
	{
		var group = new GroupModel(null)
			..codeName = _formView.codeName.value
			..displayName = _formView.displayName.value
			..description = _formView.description.value;

		Server.validateGroup(group)
			.then((ApiResponseModel r)
			{
				if (r.isSuccess)
				{
					var vm = _viewModel.groups.addModel(group);
					AppEvents.groupSelected.raise(new GroupSelectedEvent(vm));

					vm.save()
						.then((SaveResult saveResult) => onSuccess())
						.catchError((Error error) => _formView.fieldValidationError.innerHtml = error.toString());
				}
				else
				{
					_formView.fieldValidationError.innerHtml = r.error;
				}
			})
			.catchError((Error error) => _formView.fieldValidationError.innerHtml = error.toString());
	}
}