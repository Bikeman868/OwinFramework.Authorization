import 'dart:async';
import '../../MVVM/Mvvm.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../Views/Groups/GroupDisplayView.dart';

// Provides one way binding of a GroupDisplayView to a group ID. When the bound group
// ID changes, the view will be attached to the group view model with that ID.

class BoundGroupView extends BoundView<GroupViewModel, int, GroupDisplayView>
{
	BoundGroupView (GroupDisplayView view)
	{
		this.view = view;
	}
	
	void onBindingChange(GroupViewModel viewModel)
	{
		view.viewModel = viewModel;
	}

	StreamSubscription<GroupViewModel> subscribeToView(GroupDisplayView view)
	{
		return null;
	}
}
