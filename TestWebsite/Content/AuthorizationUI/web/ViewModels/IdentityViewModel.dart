import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../Server.dart';
import '../Models/IdentityModel.dart';
import '../Models/ClaimModel.dart';
import '../ViewModels/ClaimViewModel.dart';

class IdentityViewModel extends ViewModel
{
    StringBinding identity;
		IntBinding groupId;
	  ModelList<ClaimModel, ClaimViewModel> claims;

	IdentityViewModel([IdentityModel identityModel])
	{
		identity = new StringBinding();
		groupId = new IntBinding();
		claims = new ModelList<ClaimModel, ClaimViewModel>(
			(Map json) => new ClaimModel(json),
			(ClaimModel m) => new ClaimViewModel(m));

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

			claims.models = null;
		}
		else
		{
			identity.setter = (String text) 
			{ 
				identityModel.identity = text;
				modified();
			};
			identity.getter = () => identityModel.identity;
        
			groupId.setter = (int id) 
			{ 
				identityModel.groupId = id; 
				modified();
			};
			groupId.getter = () => identityModel.groupId;

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
				// alertMessage = 'Changes to "' + model.displayName + '" group successfully saved';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'Changes to the "' + model.identity + '" identity were not saved. ' + response.error;
			}
		}
		else if (state == ChangeState.added)
		{
			var response = await Server.createIdentity(model);
			if (response.isSuccess)
			{
				_model.identity = response.id;
				result = SaveResult.saved;
				alertMessage = 'New identity "' + model.identity + '" successfully added';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'New identity "' + model.identity + '" was not added. ' + response.error;
			}
		}
		else if (state == ChangeState.deleted)
		{
			var response = await Server.deleteIdentity(model);
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

