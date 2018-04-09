import 'dart:async';
import '../../MVVM/Mvvm.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../Views/Groups/GroupDisplayView.dart';

class BoundGroupView extends BoundView<GroupViewModel, int, GroupDisplayView>
{
	FormatFunction<String> formatMethod;

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
