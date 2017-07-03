import '../../MVVM/View.dart';

import '../../ViewModels/AuthorizationViewModel.dart';

import '../Permissions/PermissionListView.dart';

class ManageAuthorizationView extends View
{
	ManageAuthorizationView([AuthorizationViewModel viewModel])
	{
		addHeading(2, 'Authorization');

		var view = new PermissionListView(viewModel.permissionList);
		view.displayIn(addDiv());
	}
}

