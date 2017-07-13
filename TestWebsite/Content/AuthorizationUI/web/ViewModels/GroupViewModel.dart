import 'dart:html';
import 'dart:async';

import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';
import '../MVVM/ModelList.dart';
import '../MVVM/StringBinding.dart';
import '../MVVM/Events.dart';

import '../Server.dart';
import '../Events/AppEvents.dart';

import '../ViewModels/GroupListViewModel.dart';

import '../Models/ApiResponseModel.dart';
import '../Models/GroupModel.dart';

class GroupViewModel extends ViewModel
{
    StringBinding codeName;
    StringBinding displayName;
    StringBinding description;

	GroupViewModel([GroupModel model])
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

	GroupModel _model;
	GroupModel get model => _model;

	void set model(GroupModel value)
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
			Server.getGroup(_model.id)
				.then((m) => model = m);
		}
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		SaveResult result = SaveResult.unmodified;
		String alertMessage;

		if (state == ChangeState.modified)
		{
			var response = await Server.updateGroup(model);
			if (response.isSuccess)
			{
				result = SaveResult.saved;
				alertMessage = 'Changes to "' + model.displayName + '" group successfully saved';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'Changes to "' + model.displayName + '" group were not saved. ' + response.error;
			}
		}
		else if (state == ChangeState.added)
		{
			var response = await Server.createGroup(model);
			if (response.isSuccess)
			{
				_model.id = response.id;
				result = SaveResult.saved;
				alertMessage = 'New "' + model.displayName + '" group successfully added';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'New "' + model.displayName + '" group was not added. ' + response.error;
			}
		}
		else if (state == ChangeState.deleted)
		{
			/*
			var response = await Server.deleteGroup(model.id);
			if (response.isSuccess)
			{
				result = SaveResult.saved;
				alertMessage = 'The "' + model.displayName + '" group was successfully deleted';
			}
			else
			{
				result = SaveResult.failed;
				alertMessage = 'The "' + model.displayName + '" group was not deleted. ' + response.error;
			}
			*/
			result = SaveResult.failed;
			alertMessage = 'Deleting groups requires another group to assign the users to';
		}
		else
		{
			alertMessage = 'There were no changes to the "' + model.displayName + '" group to save';
		}

		if (alert) MvvmEvents.alert.raise(alertMessage);

		return result;
	}

	String toString() => _model.toString();
}

