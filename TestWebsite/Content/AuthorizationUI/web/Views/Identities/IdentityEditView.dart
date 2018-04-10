import '../../MVVM/Mvvm.dart';
import '../../ViewModels/IdentityViewModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../Views/Base/EditView.dart';
import '../../Views/Identities/IdentityEditFormView.dart';
import '../../Views/Groups/GroupDropdownSelectView.dart';
import '../../Views/Groups/BoundGroupView.dart';

class IdentityEditView extends EditView
{
	AuthorizationViewModel _authorizationViewModel;
	GroupDropdownSelectView _groupSelector;
	BoundGroupView _groupView;

	IdentityEditView(
		this._authorizationViewModel, 
		[
			IdentityViewModel viewModel
		])
	{
		var identityEditFormView = merge(
			new IdentityEditFormView(_authorizationViewModel.groupList, _authorizationViewModel.groupRoleList)) 
			as IdentityEditFormView;

		_groupSelector = identityEditFormView.groupSelector;

		_groupView = new BoundGroupView(identityEditFormView.groupView);

		this.viewModel = viewModel;
	}

	IdentityViewModel _viewModel;
	IdentityViewModel get viewModel => _viewModel;

	void set viewModel(IdentityViewModel identityViewModel)
	{
		_viewModel = identityViewModel;
		if (identityViewModel == null)
		{
			_groupSelector.groupBinding = null;
			_groupView.binding = null;
		}
		else
		{
			_groupSelector.groupBinding = identityViewModel.group;
			_groupView.binding = identityViewModel.group;
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

	void cancelEdits(void onSuccess())
	{
		_viewModel.reload();
		onSuccess();
	}
}