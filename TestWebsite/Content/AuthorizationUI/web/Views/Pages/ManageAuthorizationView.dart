import '../../MVVM/View.dart';

import '../../ViewModels/AuthorizationViewModel.dart';

import '../Panels/EditableListView.dart';
import '../Permissions/PermissionListSelectView.dart';
import '../Permissions/PermissionListEditView.dart';
import '../Permissions/NewPermissionView.dart';

class ManageAuthorizationView extends View
{
	ManageAuthorizationView([AuthorizationViewModel viewModel])
	{
		addHeading(2, 'Authorization');

		var view = new EditableListView(
			'Permissions',
			new PermissionListSelectView(viewModel.permissionList),
			new PermissionListEditView(viewModel.permissionList),
			new NewPermissionView(viewModel.permissionList));

		view.displayIn(addDiv());
	}
}

