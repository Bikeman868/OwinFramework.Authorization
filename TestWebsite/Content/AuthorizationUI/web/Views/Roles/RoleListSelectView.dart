import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Events/AppEvents.dart';

import '../../Models/RoleModel.dart';

import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/RoleListViewModel.dart';

import 'RoleNameView.dart';

class RoleListSelectView extends View
{
	BoundList<RoleModel, RoleViewModel, RoleNameView> _rolesBinding;

	RoleListSelectView([RoleListViewModel viewModel])
	{
		addBlockText(
			'These are the currently defined roles in this system. Granting a role to ' +
			'a group of users will give them access to functionallity within the system.', 
			className: 'help-note');

		_rolesBinding = new BoundList<RoleModel, RoleViewModel, RoleNameView>(
			(vm) => new RoleNameView(vm), addList(), allowAdd: false, allowRemove: false,
			selectionMethod: (vm) => AppEvents.roleSelected.raise(new RoleSelectedEvent(vm)));

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
}