import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../Server.dart';
import '../Models/RoleModel.dart';

class RoleViewModel extends ViewModel
{
    StringBinding codeName;
    StringBinding displayName;
    StringBinding description;

	int id;

	RoleViewModel([RoleModel model])
	{
		codeName = new StringBinding();
		displayName = new StringBinding();
		description = new StringBinding();

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	RoleModel _model;
	RoleModel get model => _model;

	void set model(RoleModel value)
	{
		_model = value;

		if (value == null)
		{
			codeName.setter = null;
			codeName.getter = null;
        
			displayName.setter = null;
			displayName.getter = null;

			description.setter = null;
			description.getter = null;
		}
		else
		{
			id = value.id;

			codeName.setter = (String text) 
			{ 
				value.codeName = text;
				modified();
			};
			codeName.getter = () => value.codeName;
        
			displayName.setter = (String text) 
			{ 
				value.displayName = text; 
				modified();
			};
			displayName.getter = () => value.displayName;
        
			description.setter = (String text) 
			{ 
				value.description = text; 
				modified();
			};
			description.getter = () => value.description;
		}

		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [];
	}

	void reload()
	{
		if (_model != null)
		{
			Server.getRole(_model.id)
				.then((m) => model = m);
		}
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.unmodified;
		String alertMessage;

		if (state == ChangeState.modified)
		{
			var response = await Server.updateRole(model);
			if (response.isSuccess)
			{
				result = SaveResult.saved;
				// alertMessage = 'Changes to "' + model.displayName + '" role successfully saved';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'Changes to "' + model.displayName + '" role were not saved. ' + response.error;
			}
		}
		else if (state == ChangeState.added)
		{
			var response = await Server.createRole(model);
			if (response.isSuccess)
			{
				_model.id = response.id;
				result = SaveResult.saved;
				alertMessage = 'New "' + model.displayName + '" role successfully added';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'New "' + model.displayName + '" role was not added. ' + response.error;
			}
		}
		else if (state == ChangeState.deleted)
		{
			var response = await Server.deleteRole(model.id);
			if (response.isSuccess)
			{
				result = SaveResult.saved;
				alertMessage = 'The "' + model.displayName + '" role was successfully deleted';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'The "' + model.displayName + '" role was not deleted. ' + response.error;
			}
		}
		else
		{
			alertMessage = 'There were no changes to the "' + model.displayName + '" role to save';
		}

		if (alert && alertMessage != null && alertMessage.length > 0)
			MvvmEvents.alert.raise(alertMessage);

		return result;
	}

	String toString() => _model.toString();
}

