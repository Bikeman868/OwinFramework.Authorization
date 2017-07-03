import '../MVVM/Model.dart';

import '../Models/ClaimModel.dart';

class IdentityModel extends Model
{
	IdentityModel(Map json) : super(json);

	String get identity => getProperty('identity');
	set identity(String value) { setProperty('identity', value); }
  
	List<ClaimModel> get claims => getList('claims', (json) => new ClaimModel(json));
	set claims(List<ClaimModel> value) { setList('claims', value); }

	String toString() => identity;
}

