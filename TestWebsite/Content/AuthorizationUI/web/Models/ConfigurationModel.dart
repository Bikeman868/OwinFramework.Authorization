import '../MVVM/Mvvm.dart';

class ConfigurationModel extends Model
{
	ConfigurationModel(Map json) : super(json);

	List<String> get displayNameClaims => getProperty('displayNameClaims');
	set name(List<String> value) { setProperty('displayNameClaims', value); }
  
	String toString() => 'UI configuration';
}

