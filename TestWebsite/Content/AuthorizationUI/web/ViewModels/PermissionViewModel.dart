import 'dart:html';
import 'dart:async';

import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';
import '../MVVM/ModelList.dart';
import '../MVVM/StringBinding.dart';
import '../MVVM/Events.dart';

import '../Server.dart';
import '../Events/AppEvents.dart';

import '../ViewModels/PermissionListViewModel.dart';

import '../Models/ApiResponseModel.dart';
import '../Models/PermissionModel.dart';

class PermissionViewModel extends ViewModel
{
    StringBinding codeName;
    StringBinding displayName;
    StringBinding resource;
    StringBinding description;

	int id;

	PermissionViewModel([PermissionModel model])
	{
		codeName = new StringBinding();
		displayName = new StringBinding();
		resource = new StringBinding();
		description = new StringBinding();

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	PermissionModel _model;
	PermissionModel get model => _model;

	void set model(PermissionModel value)
	{
		_model = value;

		if (value == null)
		{
			codeName.setter = null;
			codeName.getter = null;
        
			displayName.setter = null;
			displayName.getter = null;

			resource.setter = null;
			resource.getter = null;

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
        
			resource.setter = (String text) 
			{ 
				value.resource = text; 
				modified();
			};
			resource.getter = () => value.resource;
        
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
			Server.getPermission(_model.id)
				.then((m) => model = m);
		}
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.unmodified;
		String alertMessage;

		if (state == ChangeState.modified)
		{
			var response = await Server.updatePermission(model);
			if (response.isSuccess)
			{
				result = SaveResult.saved;
				// alertMessage = 'Changes to "' + model.displayName + '" permission successfully saved';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'Changes to "' + model.displayName + '" permission were not saved. ' + response.error;
			}
		}
		else if (state == ChangeState.added)
		{
			var response = await Server.createPermission(model);
			if (response.isSuccess)
			{
				_model.id = response.id;
				result = SaveResult.saved;
				alertMessage = 'New "' + model.displayName + '" permission successfully added';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'New "' + model.displayName + '" permission was not added. ' + response.error;
			}
		}
		else if (state == ChangeState.deleted)
		{
			var response = await Server.deletePermission(model.id);
			if (response.isSuccess)
			{
				result = SaveResult.saved;
				alertMessage = 'The "' + model.displayName + '" permission was successfully deleted';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'The "' + model.displayName + '" permission was not deleted. ' + response.error;
			}
		}
		else
		{
			alertMessage = 'There were no changes to the "' + model.displayName + '" permission to save';
		}

		if (alert && alertMessage != null && alertMessage.length > 0)
			MvvmEvents.alert.raise(alertMessage);

		return result;
	}

	String toString() => _model.toString();
}

