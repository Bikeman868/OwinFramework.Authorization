import '../../MVVM/Mvvm.dart';
import '../../Models/RoleModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../Roles/RoleUnassignedView.dart';
import '../Roles/RoleAssignedView.dart';

class AssignGroupRolesView extends View
{
	BoundViewModelList<RoleViewModel, RoleAssignedView> _assignedRolesBinding;
	BoundViewModelList<RoleViewModel, RoleUnassignedView> _otherRolesBinding;

	AssignGroupRolesView(
		[GroupViewModel groupViewModel])
	{
		addHeading(3,	'Currently assigned roles');

		addBlockText(
			'<p>These are the roles currently assigned to this group. Removing roles from ' +
			'this group could affect all users that are in this group unless the same permissions '+
			'are granted to them via other roles assigned to the group.</p>', 
			className: 'help-note');

		_assignedRolesBinding = new BoundViewModelListRepeater<RoleViewModel, RoleAssignedView>(
			(vm) => new RoleAssignedView(_removeRole, vm), addDiv());

		addHeading(3, 'Other roles');

		addBlockText(
			'<p>These are the roles not currently assigned to this group. Adding roles to this ' +
			'group will grant the permissions defined by this role to all users in this group.',
			className: 'help-note');

		_otherRolesBinding = new BoundViewModelListRepeater<RoleViewModel, RoleUnassignedView>(
			(vm) => new RoleUnassignedView(_addRole, vm), addDiv());

		viewModel = groupViewModel;
	}

	GroupViewModel _viewModel;
	GroupViewModel get viewModel => _viewModel;

	void set viewModel(GroupViewModel value)
	{
    _viewModel = value;
		_assignedRolesBinding.binding = value.assignedRoles;
		_otherRolesBinding.binding = value.otherRoles;
	}

	void _removeRole(RoleViewModel role)
	{
		_viewModel.removeRole(role);
	}

	void _addRole(RoleViewModel role)
	{
		_viewModel.assignRole(role);
	}
}