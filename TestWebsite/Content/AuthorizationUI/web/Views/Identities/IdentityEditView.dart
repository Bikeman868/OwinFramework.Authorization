import '../../MVVM/Mvvm.dart';
import '../../ViewModels/IdentityViewModel.dart';
import '../../Views/Base/EditView.dart';
import '../../Views/Identities/IdentityEditFormView.dart';

class IdentityEditView extends EditView
{
	IdentityEditView([IdentityViewModel viewModel])
	{
	}

	IdentityViewModel _viewModel;
	IdentityViewModel get viewModel => _viewModel;

	void set viewModel(IdentityViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
		}
		else
		{
		}
	}

	void saveEdits(void onSuccess())
	{
		_viewModel.save();
		onSuccess();
	}
}