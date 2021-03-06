﻿import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../Server.dart';
import '../Models/IdentityModel.dart';
import '../Models/ClaimModel.dart';
import '../ViewModels/ClaimViewModel.dart';
import '../ViewModels/AuthorizationViewModel.dart';
import '../ViewModels/GroupViewModel.dart';

class IdentityViewModel extends ViewModel
{
	StringBinding identity;
	IntBinding groupId;
	StringBinding displayName;
	ViewModelBinding<GroupViewModel, int> group;
	ModelList<ClaimModel, ClaimViewModel> claims;

	AuthorizationViewModel _authorizationViewModel;

	IdentityViewModel(
		this._authorizationViewModel,
		[
			IdentityModel identityModel
		])
	{
		identity = new StringBinding();
		groupId = new IntBinding();
		displayName = new StringBinding();

		group = new ViewModelBinding<GroupViewModel, int>(
			groupId,
			(int groupId) => _authorizationViewModel.groupList.groups.viewModels.firstWhere((g) => g.id == groupId, orElse: () => null),
			(GroupViewModel group) => group.id);

		claims = new ModelList<ClaimModel, ClaimViewModel>(
			(Map json) => new ClaimModel(json),
			(ClaimModel m) => new ClaimViewModel(_authorizationViewModel, m));

		if (identityModel == null)
			reload();
		else
			this.model = identityModel;
	}

	dispose()
	{
		model = null;
	}

	IdentityModel _model;
	IdentityModel get model => _model;

	void set model(IdentityModel identityModel)
	{
		_model = identityModel;

		if (identityModel == null)
		{
			identity.setter = null;
			identity.getter = null;
        
			groupId.setter = null;
			groupId.getter = null;

			displayName.setter = null;
			displayName.getter = null;

			claims.models = null;
		}
		else
		{
			identity.setter = null;
			identity.getter = () => identityModel.identity;
        
			groupId.setter = (int id) 
			{ 
				identityModel.groupId = id; 
				modified();
			};
			groupId.getter = () => identityModel.groupId;

			displayName.setter = null;

			_authorizationViewModel.configuration.then((configuration)
			{
				displayName.getter = () 
				{ 
					var claims = identityModel.claims;
					if (claims != null)
					{
						for (var claimName in configuration.displayNameClaims)
						{
							var claim = claims.firstWhere((c) => c.name == claimName, orElse: () => null);
							if (claim != null) return claim.value;
						}
					}
					return identityModel.identity;
				};
			});

			claims.models = identityModel.claims;
		}

		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [];
	}

	void reload()
	{
		if (identity.getter == null) return;

		Server
			.getIdentity(identity.getter())
			.then((IdentityModel identityModel) => model = identityModel)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.unmodified;
		String alertMessage;

		if (state == ChangeState.modified)
		{
			var response = await Server.updateIdentity(model);
			if (response.isSuccess)
			{
				result = SaveResult.saved;
				// alertMessage = 'Changes to "' + model.displayName + '" identity successfully saved';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'Changes to the "' + model.identity + '" identity were not saved. ' + response.error;
			}
		}
		else if (state == ChangeState.added)
		{
			result = SaveResult.failed;
			alertMessage = 'You can not add identities here, identities are managed by the Identification System';
		}
		else if (state == ChangeState.deleted)
		{
			var response = await Server.deleteIdentity(model.identity);
			if (response.isSuccess)
			{
				model = null;
				result = SaveResult.saved;
				alertMessage = 'Identity successfully deleted';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'Failed to delete identity "' + model.identity + '". ' + response.error;
			}
		}
		else
		{
			alertMessage = 'There were no changes to identity "' + model.identity + '" to save';
		}

		if (alert && alertMessage != null && alertMessage.length > 0)
			MvvmEvents.alert.raise(alertMessage);

		return result;
	}

	String toString() => _model.toString();
}

