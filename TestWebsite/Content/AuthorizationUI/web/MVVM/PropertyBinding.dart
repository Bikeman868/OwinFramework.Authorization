part of mvvm;

// Provides two-way data binding with parsing and formatting
// The binding is associated with a single data value in a model
// and many UI elements. A view model is basically a collection
// of these PropertyBinding<T> objects.
class PropertyBinding<T>
{
	SubscriptionEvent<String> onChange;
  
	String _value;
	PropertyGetFunction<T> _getter;
	PropertySetFunction<T> _setter;
	FormatFunction<T> _formatter;
	ParseFunction<T> _parser;

	PropertyBinding()
	{
		onChange = new SubscriptionEvent<String>();
	}

	PropertyGetFunction<T> get getter => _getter;
	PropertySetFunction<T> get setter => _setter;
	FormatFunction<T> get formatter => _formatter;
	ParseFunction<T> get parser => _parser;

  // Specifies how to get the current value of the bound value
	void set getter (PropertyGetFunction<T> value)
	{
		_getter = value;
		_broadcastChange();
	}

	// Specifies how to save changes to the bound balue
	void set setter (PropertySetFunction<T> value)
	{
		_setter = value;
		_broadcastChange();
	}

	// Specifies how to format type T as a string
	void set formatter (FormatFunction<T> value)
	{
		_formatter = value;
		_broadcastChange();
	}

	// Specifies how to parse a string to type T
	void set parser (ParseFunction<T> value)
	{
		_parser = value;
		_broadcastChange();
	}

	// Gets the bound value as a formatted string
	String getProperty()
	{
		if (getter == null || formatter == null)
			return null;
    
		T value = getter();
		_value = formatter(value);
		return _value;
	}

	// Parses a string into the bound value
	bool setProperty(String text)
	{
		if (parser == null)
			return false;

		if (text == _value)
			return true;
    
		T value = parser(text);
    
		if (setPropertyValue(value))
		{
			_value = text;
			return true;
		}

		return false;
	}
  
	// Changes the bound value and broadcasts the change to observers
	bool setPropertyValue(T value)
	{
		if (value == null)
			return false;

		if (setter != null)
			setter(value);
    
		_broadcastChange();

		return true;
	}

	void _broadcastChange()
	{
		if (onChange != null)
		{
			String formattedValue = getProperty();
			onChange.raise(formattedValue);
		}
	}
}
