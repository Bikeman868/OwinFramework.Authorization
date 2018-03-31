import '../Models/ApiResponseModel.dart';
import '../Models/IdentityModel.dart';

class NewIdentityResponseModel extends ApiResponseModel
{
	NewIdentityResponseModel(Map json) : super(json);

	IdentityModel get identity => getModel('identity', (map) => new IdentityModel(map));
	set identity(IdentityModel value) { setModel('identity', value); }
  
	String toString()
	{
		if (isSuccess) return result + ' new identity is ' + identity.toString();
		return result + ': ' + error;
	}
}
