import '../MVVM/Mvvm.dart';
import '../ViewModels/AuthorizationViewModel.dart';
import '../ViewModels/GroupListViewModel.dart';
import '../ViewModels/RoleListViewModel.dart';
import '../ViewModels/GroupViewModel.dart';
import '../ViewModels/RoleViewModel.dart';
import '../Models/ParentChildModel.dart';

class GroupRoleViewModel extends ViewModel
{
	StringBinding groupCodeName;
	StringBinding groupDisplayName;
	StringBinding groupDescription;

	StringBinding roleCodeName;
	StringBinding roleDisplayName;
	StringBinding roleDescription;

	AuthorizationViewModel _authorizationViewModel;
	GroupListViewModel _groupListViewModel;
	RoleListViewModel _roleListViewModel;

	GroupRoleViewModel(
		this._authorizationViewModel,
		[
			ParentChildModel model
		])
	{
		_groupListViewModel = _authorizationViewModel.groupList;
		_roleListViewModel = _authorizationViewModel.roleList;

		groupCodeName = new StringBinding();
		groupDisplayName = new StringBinding();
		groupDescription = new StringBinding();

		roleCodeName = new StringBinding();
		roleDisplayName = new StringBinding();
		roleDescription = new StringBinding();

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	ParentChildModel _model;
	ParentChildModel get model => _model;

  int groupId;
  int roleId;

	void set model(ParentChildModel value)
	{
		_model = value;

		if (value == null)
		{
			groupId = -1;
			roleId = -1;

			groupCodeName.getter = null;
			groupDisplayName.getter = null;
			groupDescription.getter = null;

			roleCodeName.getter = null;
			roleDisplayName.getter = null;
			roleDescription.getter = null;
		}
		else
		{
			groupId = value.parentId;
			roleId = value.childId;

			ViewModelGetter<GroupViewModel> groupViewModel = ()
			{
				return _groupListViewModel.groups.findViewModel((groupViewModel) => groupViewModel.id == groupId);
			};

			ViewModelGetter<RoleViewModel> roleViewModel = ()
			{
				return _roleListViewModel.roles.findViewModel((roleViewModel) => roleViewModel.id == roleId);
			};

			groupCodeName.getter = ()
			{
				var vm  = groupViewModel();
				if (vm == null) return '';
				return vm.codeName.getProperty();
			};

			groupDisplayName.getter = ()
			{
				var vm  = groupViewModel();
				if (vm == null) return '';
				return vm.displayName.getProperty();
			};

			groupDescription.getter = ()
			{
				var vm  = groupViewModel();
				if (vm == null) return '';
				return vm.description.getProperty();
			};

			roleCodeName.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.codeName.getProperty();
			};

			roleDisplayName.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.displayName.getProperty();
			};

			roleDescription.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.description.getProperty();
			};
		}

		loaded();
	}

	String toString() => _model.toString();
}

