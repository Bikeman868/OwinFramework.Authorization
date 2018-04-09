part of mvvm;

// Provides two-way data binding between a view model property 
// and the view model it references. For example in the case where
// a view model contains an ID that references another view model.
// This can be used in view models to provide a lookup facility enabling
// UI elements to bind to the referenced view model.
class ViewModelBinding<TVM extends ViewModel, T>
{
	SubscriptionEvent<TVM> onChange;
  
	TVM _value;

	PropertyGetFunction<T> _getter;
	PropertySetFunction<T> _setter;

	ViewModelLookupFunction<TVM, T> _lookupFunction;
	ViewModelReferenceFunction<TVM, T> _referenceFunction;

	ViewModelBinding(
		PropertyBinding<T> propertyBinding,
		ViewModelLookupFunction<TVM, T> lookupFunction,
		ViewModelReferenceFunction<TVM, T> referenceFunction)
	{
		onChange = new SubscriptionEvent<TVM>();

		_lookupFunction = lookupFunction;
		_referenceFunction = referenceFunction;

		this.propertyBinding = propertyBinding;
	}

	PropertyBinding<T> _propertyBinding;
	PropertyBinding<T> get propertyBinding => _propertyBinding;

	ViewModelLookupFunction<TVM, T> get lookupFunction => _lookupFunction;
	ViewModelReferenceFunction<TVM, T> get referenceFunction => _referenceFunction;

	// Specifies how to get and set the reference value from a view model property
	StreamSubscription<String> _propertyChangedSubscription;
	void set propertyBinding (PropertyBinding<T> value)
	{
		if (_propertyChangedSubscription != null)
		{
			_propertyChangedSubscription.cancel();
			_propertyChangedSubscription = null;
		}

		if (value != null)
		{
			_propertyChangedSubscription = value.onChange.listen(_boundPropertyChanged);
		}

		_propertyBinding = value;
		_broadcastChange();
	}

	// Specifies how to find the view model from its reference
	void set lookupFunction (ViewModelLookupFunction<TVM, T> value)
	{
		_lookupFunction = value;
		_broadcastChange();
	}

	// Specifies how to extract a reference from a view model
	void set referenceFunction (ViewModelReferenceFunction<TVM, T> value)
	{
		_referenceFunction = value;
		_broadcastChange();
	}

	// Retrieves the current value of the reference and looks up the view model that it references
	TVM getViewModel()
	{
		if (_propertyBinding == null || _propertyBinding.getter == null || _lookupFunction == null)
			return null;
    
		T value = _propertyBinding.getter();
		_value = _lookupFunction(value);
		return _value;
	}
  
	// Extracts a reference from the view model and saves this as the view model reference
	bool setViewModel(TVM viewModel)
	{
		if (_referenceFunction == null)
			return false;

		if (viewModel == _value)
			return true;
    
		T value = _referenceFunction(viewModel);
    
		if (value == null)
			return false;

		_value = viewModel;

		if (_propertyBinding != null)
			_propertyBinding.setPropertyValue(value);
    else
			_broadcastChange();

		return true;
	}

	void _boundPropertyChanged(String setPropertyValue)
	{
		_broadcastChange();
	}

	void _broadcastChange()
	{
		if (onChange != null)
		{
			TVM viewModel = getViewModel();
			onChange.raise(viewModel);
		}
	}
}
