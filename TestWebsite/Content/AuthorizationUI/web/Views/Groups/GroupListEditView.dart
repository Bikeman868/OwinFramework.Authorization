import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/Enums.dart';

import '../../Models/GroupModel.dart';

import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Groups/GroupNameView.dart';

class GroupListEditView extends EditView
{
	BoundList<GroupModel, GroupViewModel, GroupNameView> _groupsBinding;

	GroupListEditView([GroupListViewModel viewModel])
	{
		addBlockText(
			'<p>Remove groups that you no longer need. If your application ' +
			'is checking a group before allowing access to a feature and you ' +
			'remove that group, then the feature will become unavailable. In ' +
			'general only the software development team should manage groups ' +
			'because they know which groups the application is checking for.</p>',
			className: 'help-note');

		_groupsBinding = new BoundList<GroupModel, GroupViewModel, GroupNameView>(
			(vm) => new GroupNameView(vm), addList(), allowAdd: false);

		this.viewModel = viewModel;
	}

	GroupListViewModel _viewModel;
	GroupListViewModel get viewModel => _viewModel;

	void set viewModel(GroupListViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_groupsBinding.binding = null;
		}
		else
		{
			_groupsBinding.binding = value.groups;
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