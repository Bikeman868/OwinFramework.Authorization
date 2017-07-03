﻿import '../MVVM/Model.dart';

class RoleModel extends Model
{
	RoleModel(Map json) : super(json);

	String get codeName => getProperty('codeName');
	set codeName(String value) { setProperty('codeName', value); }
  
	String get displayName => getProperty('displayName');
	set displayName(String value) { setProperty('displayName', value); }
  
	String get description => getProperty('description');
	set description(String value) { setProperty('description', value); }
  
	String toString() => displayName + ' role';
}
