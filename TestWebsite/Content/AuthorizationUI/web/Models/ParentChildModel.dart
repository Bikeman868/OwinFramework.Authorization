import '../MVVM/Model.dart';

class ParentChildModel extends Model
{
	ParentChildModel(Map json) : super(json);

	int get parentId => getProperty('parentId');
	set parentId(int value) { setProperty('parentId', value); }

	int get childId => getProperty('childId');
	set childId(int value) { setProperty('childId', value); }
  
	String toString() => childId.toString() + ' => ' + parentId.toString();
}

