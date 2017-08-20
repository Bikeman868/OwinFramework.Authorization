import '../MVVM/Mvvm.dart';

class ApiResponseModel extends Model
{
	ApiResponseModel(Map json) : super(json);

	String get result => getProperty('result');
	set result(String value) { setProperty('result', value); }
  
	String get error => getProperty('error');
	set error(String value) { setProperty('error', value); }

	bool get isSuccess => result == 'Success';
  
	String toString()
	{
		if (isSuccess) return result;
		return result + ': ' + error;
	}
}
