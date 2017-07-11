import '../MVVM/Model.dart';

class GroupModel extends Model
{
	GroupModel(Map json) : super(json);

	int get id => getProperty('id');
	set id(int value) { setProperty('id', value); }

	String get codeName => getProperty('codeName');
	set codeName(String value) { setProperty('codeName', value); }
  
	String get displayName => getProperty('displayName');
	set displayName(String value) { setProperty('displayName', value); }
  
	String get description => getProperty('description');
	set description(String value) { setProperty('description', value); }
  
	String toString() => displayName + ' group';
}

