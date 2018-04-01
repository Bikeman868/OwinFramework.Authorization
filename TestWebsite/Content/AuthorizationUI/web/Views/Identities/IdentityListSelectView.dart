import 'dart:html';
import '../../Server.dart';
import '../../MVVM/Mvvm.dart';
import '../../Events/AppEvents.dart';
import '../../Models/IdentityModel.dart';
import '../../ViewModels/IdentityViewModel.dart';
import '../../ViewModels/IdentityListViewModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';

import 'IdentityNameView.dart';

class IdentityListSelectView extends View
{
	BoundList<IdentityModel, IdentityViewModel, IdentityNameView> _identitiesBinding;
	InputElement searchText;
	Element _resultContainer;

	AuthorizationViewModel _authorizationViewModel;

	IdentityListSelectView(this._authorizationViewModel, [IdentityListViewModel viewModel])
	{
		addBlockText(
			'Search for users by entering some search text below.', 
			className: 'help-note');

		Element _formContainer = addContainer();
		searchText = addInput(parent: _formContainer);
		addInlineText('&nbsp;', parent: _formContainer);
		addButton('Search', (MouseEvent e) => search(), parent: _formContainer);

		searchText.onKeyUp.listen((KeyboardEvent e)
		{
			if (e.keyCode == 13)
			{
				e.preventDefault();
				search();
			}
		});

		_resultContainer = addContainer();
		_resultContainer.hidden = true;

		addHR(parent: _resultContainer);
		
		addBlockText(
			'These are the identities that match your search phrase.', 
			className: 'help-note',
			parent: _resultContainer);

		_identitiesBinding = new BoundList<IdentityModel, IdentityViewModel, IdentityNameView>(
			(vm) => new IdentityNameView(vm), addList(parent: _resultContainer), allowAdd: false, allowRemove: false,
			selectionMethod: (vm) => AppEvents.identitySelected.raise(new IdentitySelectedEvent(vm)));
	}

	void search()
	{
		if (searchText.value.length > 1)
		{
		Server
			.findIdentities(searchText.value)
			.then((identityModels)
			{
				_resultContainer.hidden = false;
				this.viewModel = new IdentityListViewModel(_authorizationViewModel, identityModels);
				if (this.viewModel.identities.viewModels.length > 0)
				{
					AppEvents.identitySelected.raise(new IdentitySelectedEvent(this.viewModel.identities.viewModels.first));
				}
			});
		}
	}

	IdentityListViewModel _viewModel;
	IdentityListViewModel get viewModel => _viewModel;

	void set viewModel(IdentityListViewModel viewModel)
	{
		_viewModel = viewModel;
		if (viewModel == null)
		{
			_identitiesBinding.binding = null;
		}
		else
		{
			_identitiesBinding.binding = viewModel.identities;
		}
	}
}