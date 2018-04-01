import '../MVVM/Mvvm.dart';
import '../Models/ClaimModel.dart';
import '../ViewModels/AuthorizationViewModel.dart';

class ClaimViewModel extends ViewModel
{
	StringBinding name;
	StringBinding value;
	IntBinding status;
	StringBinding statusText;

	AuthorizationViewModel _authorizationViewModel;

	ClaimViewModel(this._authorizationViewModel, [ClaimModel model])
	{
		name = new StringBinding();
		value = new StringBinding();
		status = new IntBinding();
		statusText = new StringBinding();

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	ClaimModel _model;
	ClaimModel get model => _model;

	void set model(ClaimModel claimModel)
	{
		_model = claimModel;

		if (claimModel == null)
		{
			name.setter = null;
			name.getter = null;
        
			value.setter = null;
			value.getter = null;

			status.setter = null;
			status.getter = null;

			statusText.setter = null;
			statusText.getter = null;
		}
		else
		{
			name.setter = (String text) 
			{ 
				claimModel.name = text;
				modified();
			};
			name.getter = () => claimModel.name;
        
			value.setter = (String text) 
			{ 
				claimModel.value = text; 
				modified();
			};
			value.getter = () => claimModel.value;
        
			status.setter = (int status) 
			{ 
				claimModel.status = status; 
				modified();
			};
			status.getter = () => claimModel.status;

			statusText.setter = (String text)
			{
				if (text == 'Unknown') claimModel.status = 0;
				else if (text == 'Verified') claimModel.status = 1;
				else if (text == 'Unverified') claimModel.status = 2;
			};
			statusText.getter = ()
			{
				if (claimModel.status == 1) return 'Verified';
				if (claimModel.status == 2) return 'Unverified';
				return 'Unknown';
			};
		}
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [];
	}

	String toString() => _model.toString();
}

