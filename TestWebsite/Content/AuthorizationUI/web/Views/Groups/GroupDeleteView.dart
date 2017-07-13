import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Enums.dart';
import '../../MVVM/BoundLabel.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/GroupModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Groups/GroupEditFormView.dart';

class GroupDeleteView extends EditView
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	GroupDeleteView(this._groupListViewModel, [GroupViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addDiv(),
			formatMethod: (s) => 
				'<p>If there are any users currently assigned to the "' + s + '" group then ' +
				'they need to be assigned to a different group when the "' + s + '" group ' + 
				'is deleted.</p>');

		addBlockText('<p>Note that these users will have all of their permissions changed to ' +
			'the permissions assigned to their new group.');

		_descriptionBinding = new BoundLabel<String>(addDiv());

		//var form = addForm();
		//_displayNameBinding = new BoundField<String>(addLabeledCombo(form, 'New group'));

		this.viewModel = viewModel;
	}

	GroupViewModel _viewModel;
	GroupViewModel get viewModel => _viewModel;

	GroupListViewModel _groupListViewModel;

	void set viewModel(GroupViewModel value)
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
	}
}