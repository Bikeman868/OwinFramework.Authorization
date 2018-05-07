import '../../MVVM/Mvvm.dart';
import '../../Models/RoleModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/RoleListViewModel.dart';
import '../../Views/Base/EditView.dart';
import '../../Views/Roles/RoleNameView.dart';

class RoleListEditView extends EditView
{
	BoundModelListList<RoleModel, RoleViewModel, RoleNameView> _rolesBinding;

	RoleListEditView([RoleListViewModel viewModel])
	{
		addBlockText(
			'<p>Remove roles that you no longer need. If your application ' +
			'is checking a role before allowing access to a feature and you ' +
			'remove that role, then the feature will become unavailable. In ' +
			'general only the software development team should manage roles ' +
			'because they know which roles the application is checking for.</p>',
			className: 'help-note');

		_rolesBinding = new BoundModelListList<RoleModel, RoleViewModel, RoleNameView>(
			(vm) => new RoleNameView(vm), addList(), allowAdd: false);

		this.viewModel = viewModel;
	}

	RoleListViewModel _viewModel;
	RoleListViewModel get viewModel => _viewModel;

	void set viewModel(RoleListViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_rolesBinding.binding = null;
		}
		else
		{
			_rolesBinding.binding = value.roles;
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