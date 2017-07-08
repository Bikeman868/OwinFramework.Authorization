import '../MVVM/Model.dart';

class ClaimModel extends Model
{
	ClaimModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	String get value => getProperty('value');
	set value(String value) { setProperty('value', value); }
  
	int get status => getProperty('status');
	set status(int value) { setProperty('status', value); }
  
	String toString() => name + ' is ' + value;
}

