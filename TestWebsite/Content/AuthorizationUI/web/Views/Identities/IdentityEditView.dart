import '../../MVVM/Mvvm.dart';
import '../../ViewModels/IdentityViewModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../Views/Base/EditView.dart';
import '../../Views/Identities/IdentityEditFormView.dart';
import '../../Views/Groups/GroupDropdownSelectView.dart';

class IdentityEditView extends EditView
{
	AuthorizationViewModel _authorizationViewModel;
	GroupDropdownSelectView _groupSelector;

	IdentityEditView(
		this._authorizationViewModel, 
		[
			IdentityViewModel viewModel
		])
	{
		var identityEditFormView = merge(new IdentityEditFormView(_authorizationViewModel.groupList)) as IdentityEditFormView;
		_groupSelector = identityEditFormView.groupSelector;

		this.viewModel = viewModel;
	}

	IdentityViewModel _viewModel;
	IdentityViewModel get viewModel => _viewModel;

	void set viewModel(IdentityViewModel identityViewModel)
	{
		_viewModel = identityViewModel;
		if (identityViewModel == null)
		{
			_groupSelector.groupIdBinding = null;
		}
		else
		{
			_groupSelector.groupIdBinding = identityViewModel.groupId;
		}
	}

	void saveEdits(void onSuccess())
	{
		_viewModel
			.save()
			.then((SaveResult result)
			{
				if (result == SaveResult.saved)
					onSuccess();
			});
	}
}