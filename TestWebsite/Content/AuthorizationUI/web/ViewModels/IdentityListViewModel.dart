import '../MVVM/Mvvm.dart';
import '../ViewModels/IdentityViewModel.dart';
import '../Models/IdentityModel.dart';

class IdentityListViewModel extends ViewModel
{
    ModelList<IdentityModel, IdentityViewModel> identities;

	IdentityListViewModel([List<IdentityModel> identityModels]): super(false)
	{
		identities = new ModelList<IdentityModel, IdentityViewModel>(
			(Map json) => new IdentityModel(null),
			(IdentityModel m) => new IdentityViewModel(m));

			models = identityModels;
	}

	dispose()
	{
		models = null;
	}

	List<IdentityModel> get models
	{
		return identities.models;
	}

	void set models(List<IdentityModel> value)
	{
		identities.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [identities];
	}

	String toString() => 'identity list';
}

