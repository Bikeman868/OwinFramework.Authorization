import '../Models/ApiResponseModel.dart';

class NewRecordResponseModel extends ApiResponseModel
{
	NewRecordResponseModel(Map json) : super(json);

	int get id => getProperty('id');
	set id(int value) { setProperty('id', value); }
  
	String toString()
	{
		if (isSuccess) return result + ' new id is ' + id.toString();
		return result + ': ' + error;
	}
}

