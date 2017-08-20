import '../MVVM/Mvvm.dart';
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

	GroupListViewModel _groupListViewModel;
	RoleListViewModel _roleListViewModel;

	GroupRoleViewModel(
		this._groupListViewModel,
		this._roleListViewModel,
		[
			ParentChildModel model
		])
	{
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

	void set model(ParentChildModel value)
	{
		_model = value;

		if (value == null)
		{
			groupCodeName.getter = null;
			groupDisplayName.getter = null;
			groupDescription.getter = null;

			roleCodeName.getter = null;
			roleDisplayName.getter = null;
			roleDescription.getter = null;
		}
		else
		{
			var groupId = value.parentId;
			var roleId = value.childId;

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
				return vm.codeName.getter();
			};

			groupDisplayName.getter = ()
			{
				var vm  = groupViewModel();
				if (vm == null) return '';
				return vm.displayName.getter();
			};

			groupDescription.getter = ()
			{
				var vm  = groupViewModel();
				if (vm == null) return '';
				return vm.description.getter();
			};

			roleCodeName.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.codeName.getter();
			};

			roleDisplayName.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.displayName.getter();
			};

			roleDescription.getter = ()
			{
				var vm  = roleViewModel();
				if (vm == null) return '';
				return vm.description.getter();
			};
		}

		loaded();
	}

	String toString() => _model.toString();
}

